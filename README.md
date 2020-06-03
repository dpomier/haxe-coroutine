coroutine
=======
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md)

*Support from Haxe `3.4.x` to `4.1.x`*

This library is based on [yield](https://github.com/dpomier/haxe-yield) to provide a Unity-like cross-platform implementation.

Example
-----

```haxe
import coroutine.Routine;
import coroutine.CoroutineRunner;

class Example {

    static var runner = new CoroutineRunner();
    static var processor = new CoroutineProcessor(runner);

    static function loop() {

        // Custom the update of your coroutines
        processor.updateEnterFrame();
        processor.updateTimer(haxe.Timer.stamp());
        processor.updateExitFrame();

        haxe.Timer.delay(loop, 16);
    }

    static function main() {

        loop();

        // Start a coroutine
        runner.startCoroutine( count() );

    }

    static function count() {
        var i = 0;
        while(true) {
            trace(i++);
            @yield return RoutineInstruction.WaitNextFrame;
        }
    }
}
```
The above example will trace repetitively from `"0"` to infinity (almost). You can try it with `haxe -lib coroutine --run Example.hx`.

Install
-----

To install the library, use `haxelib install coroutine` and compile your program with `-lib coroutine`.

Development Builds
-----

1. To clone the github repository, use `git clone https://github.com/dpomier/haxe-coroutine`

2. To tell haxelib where your development copy is installed, use `haxelib dev yield my/repositories/haxe-coroutine`

To return to release builds use `haxelib dev coroutine`
