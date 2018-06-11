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
	private var waitingRoutinesStack:Map<Routine, GenericStack<Routine>>;
	
	public function new () {
		
		coroutines = [];
		activeRoutines  = new GenericStack<Routine>();
		nextFrameStack  = new GenericStack<Routine>();
		endOfFrameStack = new GenericStack<Routine>();
		delayedRoutineList = new Array<Routine>();
		delayedTimeList    = new Array<Float>();
		waitingRoutinesStack = new Map<Routine, GenericStack<Routine>>();
		
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
				
				if (!waitingRoutinesStack.exists(subroutine)) {
					
					waitingRoutinesStack[subroutine] = new GenericStack<Routine>();
					
				}
				
				waitingRoutinesStack[subroutine].add(routine);
				
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
					
					for (waitingRoutines in waitingRoutinesStack) {
						
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
		
		if (waitingRoutinesStack.exists(subroutine)) {
			
			if (runWaitingRoutines) {
				
				var waitingRoutines = waitingRoutinesStack.get(subroutine);
				
				waitingRoutinesStack.remove(subroutine);
				
				for (waitingRoutine in waitingRoutines) {
					
					runRoutine(waitingRoutine);
					
				}
				
			} else {
				
				waitingRoutinesStack.remove(subroutine);
				
			}
			
		}
		
	}
	
}