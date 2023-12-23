/*
 * The MIT License
 * 
 * Copyright (C)2023 Dimitri Pomier
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package coroutine;

import haxe.Timer;
import haxe.ds.GenericStack;

class CoroutineRunner {
	private var coroutines:Array<Routine>;
	private var activeRoutines:GenericStack<Routine>;
	private var emptyStack:GenericStack<Routine>;
	private var nextFrameStack:GenericStack<Routine>;
	private var endOfFrameStack:GenericStack<Routine>;
	private var delayedRoutineList:Array<Routine>;
	private var delayedTimeList:Array<Float>;
	private var subroutineStack:Array<Routine>;
	private var waitingRoutineStack:Array<GenericStack<Routine>>;

	private static var subroutines = new Map<Int, Routine>();
	private static var subroutinesCounter:Int = 0;

	public function new() {
		coroutines = [];
		activeRoutines = new GenericStack<Routine>();

		nextFrameStack = new GenericStack<Routine>();
		endOfFrameStack = new GenericStack<Routine>();

		delayedRoutineList = new Array<Routine>();
		delayedTimeList = new Array<Float>();

		subroutineStack = new Array<Routine>();
		waitingRoutineStack = new Array<GenericStack<Routine>>();
	}

	/**
		Runs `routine` as a coroutine.
	 */
	public function startCoroutine(routine:Routine):Void {
		coroutines.push(routine);

		runRoutine(routine);
	}

	/**
		Stops `routine`.
	 */
	public function stopCoroutine(routine:Routine):Void {
		if (coroutines.remove(routine))
			removeRoutine(routine, true);
	}

	/**
		Stops every coroutines from `this` instance.
	 */
	public function stopAllCoroutines():Void {
		var i:Int = coroutines.length;

		while (--i != -1)
			removeRoutine(coroutines.pop(), false);
	}

	inline function runRoutines(routines:GenericStack<Routine>):Void {
		while (!routines.isEmpty())
			runRoutine(routines.pop());
	}

	function runRoutine(routine:Routine):Void {
		if (!routine.hasNext()) {
			coroutines.remove(routine);
			releaseSubRoutine(routine, true);
			return;
		}

		var current:Int = routine.next();

		if (current == coroutine._core.RI.waitNext()) {
			nextFrameStack.add(routine);
		} else if (current == coroutine._core.RI.waitEnd()) {
			endOfFrameStack.add(routine);
		} else if (current >= (coroutine._core.RI.waitDelay(0) : Int)) {
			delayedRoutineList.push(routine);
			delayedTimeList.push(Timer.stamp() + (current - 2) / 1000);
		} else {
			var subroutineIndex:Int = current;
			var subroutine:Routine = subroutines.get(subroutineIndex);
			subroutines.remove(subroutineIndex);

			var i:Int = subroutineStack.lastIndexOf(subroutine);
			if (i == -1) {
				i = subroutineStack.push(subroutine) - 1;
				waitingRoutineStack.push(new GenericStack<Routine>());
			}

			waitingRoutineStack[i].add(routine);
			startCoroutine(subroutine);
		}
	}

	inline function removeRoutine(routine:Routine, runWaitingRoutine:Bool):Void {
		if (!nextFrameStack.remove(routine)) {
			if (!endOfFrameStack.remove(routine)) {
				var i:Int = delayedRoutineList.indexOf(routine);
				if (i != -1) {
					delayedRoutineList.splice(i, 1);
					delayedTimeList.splice(i, 1);
				} else {
					var wasWaiting:Bool = false;

					for (waitingRoutines in waitingRoutineStack) {
						if (waitingRoutines.remove(routine)) {
							wasWaiting = true;
							break;
						}
					}

					if (!wasWaiting) {
						activeRoutines.remove(routine);
					}
				}
			}
		}

		releaseSubRoutine(routine, runWaitingRoutine);
	}

	inline function releaseSubRoutine(subroutine:Routine, runWaitingRoutines:Bool):Void {
		var length:Int = subroutineStack.length;
		var subroutineIndex:Int = DoubleArrayTools.lastIndexOf(subroutineStack, subroutine, length);

		if (subroutineIndex != -1) {
			if (runWaitingRoutines) {
				var waitingRoutines = waitingRoutineStack[subroutineIndex];
				DoubleArrayTools.eraseAt(subroutineStack, waitingRoutineStack, subroutineIndex, length);
				for (waitingRoutine in waitingRoutines) {
					runRoutine(waitingRoutine);
				}
			} else {
				DoubleArrayTools.eraseAt(subroutineStack, waitingRoutineStack, subroutineIndex, length);
			}
		}
	}
}

@:access(coroutine.CoroutineRunner)
abstract CoroutineProcessor(CoroutineRunner) {

	public static inline function of(runner:CoroutineRunner):CoroutineProcessor {
		return new CoroutineProcessor(runner);
	}

	public inline function new(runner:CoroutineRunner) {
		this = runner;
	}

	public function updateEnterFrame():Void {
		this.emptyStack = this.activeRoutines;

		this.activeRoutines = this.nextFrameStack;
		this.nextFrameStack = this.emptyStack;
		this.emptyStack = null;

		this.runRoutines(this.activeRoutines);
	}

	/**
		@param timestamp Timestamp in seconds with fractions.
	 */
	public function updateTimer(timestamp:Float):Void {
		var i:Int = this.delayedRoutineList.length;
		var last:Int = i;

		if (i != 0) {
			while (--i != -1) {
				if (timestamp > this.delayedTimeList[i]) {
					this.activeRoutines.add(this.delayedRoutineList[i]);

					this.delayedRoutineList[i] = this.delayedRoutineList[last];
					this.delayedRoutineList.pop();

					this.delayedTimeList[i] = this.delayedTimeList[last];
					this.delayedTimeList.pop();

					last--;
				}
			}

			this.runRoutines(this.activeRoutines);
		}
	}

	public function updateExitFrame():Void {
		this.emptyStack = this.activeRoutines;

		this.activeRoutines = this.endOfFrameStack;
		this.endOfFrameStack = this.emptyStack;
		this.emptyStack = null;

		this.runRoutines(this.activeRoutines);
	}
}

private extern class DoubleArrayTools {
	public static inline function lastIndexOf<K>(arrayKey:Array<K>, key:K, length:Int):Int {
		var i:Int = length;

		while (--i != -1) {
			if (arrayKey[i] == key) {
				break;
			}
		}

		return i;
	}

	public static inline function eraseAt<K, V>(arrayKey:Array<K>, arrayValue:Array<V>, index:Int, ?length:Int):Void {
		if (length == null) {
			length = arrayKey.length;
		}

		if (index == length - 1) {
			arrayKey.pop();
			arrayValue.pop();
		} else {
			arrayKey[index] = arrayKey.pop();
			arrayValue[index] = arrayValue.pop();
		}
	}
}
