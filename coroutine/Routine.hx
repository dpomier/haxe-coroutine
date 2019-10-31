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

/**
 * 
 */
typedef Routine = Iterator<RoutineInstruction>;

abstract RoutineInstruction (Int) {

    /**
	 * Wait until the next frame then resume the routine
	**/
	public static inline var WaitNextFrame:RoutineInstruction = cast 0;
	
	/**
	 * Wait until the end of the current frame then resume the routine
	**/
	public static inline var WaitEndOfFrame:RoutineInstruction = cast 1;
	
	/**
	 * Wait `s` seconds then resume the routine at the beginning of the next frame
	**/
	public static inline function WaitDelay(s:Float):RoutineInstruction {
		return cast 2 + Std.int(1000 * s);
	}
	
	/**
	 * Run the subroutine `routine` and wait until it is complete then resume the routine
	 */
	public static inline function WaitRoutine(routine:Routine):RoutineInstruction {
		@:privateAccess coroutine.CoroutineProcessor.subroutinesCounter--;
		@:privateAccess coroutine.CoroutineProcessor.subroutines.set(coroutine.CoroutineProcessor.subroutinesCounter, routine);
		return cast @:privateAccess coroutine.CoroutineProcessor.subroutinesCounter;
	}
	
	/**
	 * Wait while `f` return true.
	**/
	public static inline function WaitWhile(f:Void->Bool):RoutineInstruction {
		return WaitRoutine({
            hasNext: function () return f(),
            next: function () return WaitNextFrame
        });
	}

}