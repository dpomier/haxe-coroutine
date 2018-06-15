/*
 * The MIT License
 * 
 * Copyright (C)2018 Dimitri Pomier
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

class CoroutineHandler {
	
	private var coroutines:Array<Routine>;
	private var activeRoutines:GenericStack<Routine>;
	private var emptyStack:GenericStack<Routine>;
	private var nextFrameStack:GenericStack<Routine>;
	private var endOfFrameStack:GenericStack<Routine>;
	private var delayedRoutineList:Array<Routine>;
	private var delayedTimeList:Array<Float>;
	private var subroutineStack:Array<Routine>;
	private var waitingRoutineStack:Array<GenericStack<Routine>>;
	
	public function new () {
		
		coroutines     = [];
		activeRoutines = new GenericStack<Routine>();
		
		nextFrameStack  = new GenericStack<Routine>();
		endOfFrameStack = new GenericStack<Routine>();
		
		delayedRoutineList = new Array<Routine>();
		delayedTimeList    = new Array<Float>();
		
		subroutineStack     = new Array<Routine>();
		waitingRoutineStack = new Array<GenericStack<Routine>>();
	}
	
	public function startCoroutine (routine:Iterator<CoroutineInstruction>):Void {
		
		if (coroutines.indexOf(routine) != -1) {
			
			return;
			
		}
		
		coroutines.push(routine);
		
		runRoutine(routine);
		
	}
	
	public function stopCoroutine (routine:Iterator<CoroutineInstruction>):Void {
		
		if (coroutines.remove(routine)) {
			
			removeRoutine(routine, true);
			
		}
		
	}
	
	public function stopAllCoroutines ():Void {
		
		var i:Int = coroutines.length;
		
		while (--i != -1) {
			
			removeRoutine(coroutines.pop(), false);
			
		}
		
	}
	
	public function updateCoroutineEnterFrame ():Void {
		
		updateNextFrameRoutines();
		
		updateDelayedRoutines();
		
	}
	
	public function updateCoroutineExitFrame ():Void {
		
		updateEndOfFrameRoutines();
		
	}
	
	
	// Private Methods
	
	
	private inline function updateNextFrameRoutines ():Void {
		
		emptyStack = activeRoutines;
		
		activeRoutines = nextFrameStack;
		nextFrameStack = emptyStack;
		emptyStack = null;
		
		runActiveRoutines();
		
	}
	
	private inline function updateEndOfFrameRoutines ():Void {
		
		emptyStack = activeRoutines;
		
		activeRoutines  = endOfFrameStack;
		endOfFrameStack = emptyStack;
		emptyStack = null;
		
		runActiveRoutines();
		
	}
	
	private static var timestamp:Float;
	
	private var i:Int;
	
	private inline function updateDelayedRoutines ():Void {
		
		i = delayedRoutineList.length;
		
		if (i != 0) {
			
			timestamp = Timer.stamp();
			
			while (--i != -1) {
				
				if (timestamp > delayedTimeList[i]) {
					
					activeRoutines.add(delayedRoutineList[i]);
					
					delayedRoutineList.splice(i, 1);
					delayedTimeList.splice(i, 1);
					
				}
				
			}
			
			runActiveRoutines();
			
		}
	}
	
	private function runActiveRoutines ():Void {
		
		while (!activeRoutines.isEmpty()) {
			
			runRoutine(activeRoutines.pop());
			
		}
	}
	
	private function runRoutine (routine:Routine):Void {
		
		if (!routine.hasNext()) {
			
			coroutines.remove(routine);
			
			releaseSubRoutine(routine, true);
			
			return;
			
		}
		
		var current:CoroutineInstruction = routine.next();
		
		if (current == null) {
			
			current = CoroutineInstruction.WaitNextFrame;
			
		}
		
		switch (current) {
			
			case CoroutineInstruction.WaitNextFrame:
				
				nextFrameStack.add(routine);
				
			case CoroutineInstruction.WaitEndOfFrame:
				
				endOfFrameStack.add(routine);
				
			case CoroutineInstruction.WaitDelay(seconds):
				
				delayedRoutineList.push(routine);
				delayedTimeList.push(Timer.stamp() + seconds);
				
			case CoroutineInstruction.WaitCoroutine(subroutine):
				
				var subroutineIndex:Int = subroutineStack.lastIndexOf(subroutine);
				
				if (i == -1) {
					
					subroutineIndex = subroutineStack.push(subroutine);
					waitingRoutineStack.push(new GenericStack<Routine>());
					
				}
				
				waitingRoutineStack[subroutineIndex].add(routine);
				
				startCoroutine(subroutine);
				
		}
	}
	
	private inline function removeRoutine (routine:Routine, runWaitingRoutine:Bool):Void {
		
		if (!nextFrameStack.remove(routine)) {
			
			if (!endOfFrameStack.remove(routine)) {
				
				i = delayedRoutineList.indexOf(routine);
				
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
	
	private inline function releaseSubRoutine (subroutine:Routine, runWaitingRoutines:Bool):Void {
		
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

private extern class DoubleArrayTools {
	
	public static inline function lastIndexOf<K> (arrayKey:Array<K>, key:K, length:Int):Int {
		
		var i:Int = length;
		
		while (--i != -1) {
			
			if (arrayKey[i] == key) {
				break;
			}
			
		}
		
		return i;
		
	}
	
	public static inline function eraseAt<K, V> (arrayKey:Array<K>, arrayValue:Array<V>, index:Int, ?length:Int):Void {
		
		if (length == null) {
			
			length = arrayKey.length;
			
		}
		
		if (index == length - 1) {
			
			arrayKey.pop();
			arrayValue.pop();
			
		} else {
			
			arrayKey[index]   = arrayKey.pop();
			arrayValue[index] = arrayValue.pop();
			
		}
		
	}
	
}