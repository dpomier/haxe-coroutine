package coroutine;

enum CoroutineInstruction 
{
	WaitNextFrame;
	WaitEndOfFrame;
	WaitDelay(seconds:Float);
	
	/**
	 * run ´routine´ if it is not already running
	 */
	WaitCoroutine(routine:Iterator<CoroutineInstruction>);
}