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

/**
 * Alias for iterator of routine instructions. Can be used to start coroutine executions.
 * See `CoroutineRunner.startCoroutine` for an exemple.
 */
typedef Routine = #if display Iterator<RoutineInstruction> #else coroutine._core.Routine #end;

enum RoutineInstruction {
	/**
		Wait until the next frame, then resume the routine.
	 */
	WaitNextFrame;

	/**
		Wait until the end of the current frame, then resume the routine.
	 */
	WaitEndOfFrame;

	/**
		Wait `seconds` seconds, then resume the routine at the beginning of the next frame.
	 */
	WaitDelay(s:Float);

	/**
		Run `r` and wait until it is complete, then resume the routine.
	 */
	WaitRoutine(r:Routine);

	/**
		Wait while `f` returns `true`. The routine resumes when `false` is returned.
	 */
	WaitWhile(f:Void->Bool);
}
