package coroutine;

enum CoroutineInstruction {
	
	/**
	   Wait until the next frame then resume the routine
	**/
	WaitNextFrame;
	
	/**
	   Wait until the end of the current frame then resume the routine
	**/
	WaitEndOfFrame;
	
	/**
	   Wait `s` seconds then resume the routine at the beginning of the next frame
	**/
	WaitDelay(s:Float);
	
	/**
	 * Run the subroutine `routine` and wait until it is complete then resume the routine
	 */
	WaitCoroutine(routine:Iterator<CoroutineInstruction>);
	
}