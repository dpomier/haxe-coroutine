package coroutine._core;

#if display
typedef Routine = Iterator<coroutine.Routine.RoutineInstruction>;
#elseif (haxe_ver >= 4.000 || !cpp)
typedef Routine = Iterator<coroutine._core.RI>;
#elseif cpp
// See https://github.com/HaxeFoundation/haxe/issues/3697
abstract Routine(Dynamic) {
	@:from static inline function _(v:Iterator<coroutine._core.RI>):Routine
		return cast v;

	public inline function next():coroutine._core.RI
		return (this : Iterator<coroutine._core.RI>).next();

	public inline function hasNext():Bool
		return (this : Iterator<coroutine._core.RI>).hasNext();
}
#end
