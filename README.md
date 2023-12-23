coroutine
=======
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md)

*Support from Haxe `3.4.x` to `4.3.x`*

This library is based on [yield](https://github.com/dpomier/haxe-yield) to provide a cross-platform implementation.

Example
-----

```haxe
import coroutine.Routine;

function count():Routine {
    var i = 0;
    while(true) {
        trace(i++);
        @yield return WaitNextFrame;
    }
}
```
The above example will trace `0`, `1`, `2`, `3`, and so on at each step of the coroutine. To run, `startCoroutine` must be called as follow:
```haxe
import coroutine.CoroutineRunner;

function main() {
    // Start a coroutine
    var runner = new CoroutineRunner();
    runner.startCoroutine( count() );

    // Dummy loop for the example
    new haxe.Timer(16).run = function() {
        // Customize how/when to update your coroutines
        // Set this at your convenience in your project
        var processor = CoroutineProcessor.of(runner);
        processor.updateEnterFrame();
        processor.updateTimer(haxe.Timer.stamp());
        processor.updateExitFrame();
    }
}
```
In this example the coroutine `cout` is resuming with an interval of 16 ms.

Instructions
-----

Coroutines are functions that returns with `@yield` any enum value of `RoutineInstruction`:

```haxe
enum RoutineInstruction {
	/**
		Wait until the next frame,
        then resume the routine.
	 */
	WaitNextFrame;

	/**
		Wait until the end of the current
        frame, then resume the routine.
	 */
	WaitEndOfFrame;

	/**
		Wait `seconds` seconds, then resume the
        routine at the beginning of the next frame.
	 */
	WaitDelay(s:Float);

	/**
		Run `r` and wait until it is complete,
        then resume the routine.
	 */
	WaitRoutine(r:Routine);

	/**
		Wait while `f` returns `true`. The
        routine resumes when `false` is returned.
	 */
	WaitWhile(f:Void->Bool);
}
```

Install
-----

To install the library, use `haxelib install coroutine` and compile your program with `--library coroutine`.

Development Builds
-----

1. To clone the github repository, use `git clone https://github.com/dpomier/haxe-coroutine`

2. To tell haxelib where your development copy is installed, use `haxelib dev coroutine path/to/haxe-coroutine`

To return to release builds use `haxelib dev coroutine`
