package coroutine._;

import coroutine.Routine.RoutineInstruction;
import coroutine.CoroutineRunner;

abstract RI (Int) to Int {
	public static inline function fromNull ():RI {
		return waitNext();
	}
	public static inline function waitNext ():RI {
		return new RI(0);
	}
	public static inline function waitEnd ():RI {
		return new RI(1);
	}
	public static inline function waitDelay (s:Float):RI {
		return new RI(2 + Std.int(1000. * s));
	}
	public static inline function waitRoutine (r:Routine):RI {
		@:privateAccess CoroutineRunner.subroutinesCounter--;
		@:privateAccess CoroutineRunner.subroutines.set(CoroutineRunner.subroutinesCounter, r);
		return new RI(@:privateAccess CoroutineRunner.subroutinesCounter);
	}
	public static inline function waitWhile (f:Void->Bool):RI {
		return waitRoutine({
			hasNext: f,
			next: waitNext
		});
	}
	@:from public static inline function fromRoutineInstruction (ri:RoutineInstruction):RI {
		return switch ri {
			case WaitNextFrame:
				waitNext();
			case WaitEndOfFrame:
				waitEnd();
			case WaitDelay(s):
				waitDelay(s);
			case WaitRoutine(r):
				waitRoutine(r);
			case WaitWhile(f): 
				waitRoutine({
					hasNext: function () return f(),
					next: function () return new RI(0)
				});
		}
	}
	inline function new (v:Int) this = v;
}