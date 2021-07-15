coroutine
=======
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md)
[![TravisCI Build Status](https://travis-ci.com/dpomier/haxe-coroutine.svg?branch=master)](https://travis-ci.com/dpomier/haxe-coroutine)

*Support from Haxe `3.4.x` to `4.2.x`*

This library is based on [yield](https://github.com/dpomier/haxe-yield) to provide a cross-platform implementation.

Example
-----

```haxe
import coroutine.Routine;
import coroutine.CoroutineRunner;

function count() {
    var i = 0;
    while(true) {
        trace(i++);
        @yield return WaitNextFrame;
    }
}

function main() {
    // Start a coroutine
    var runner = new CoroutineRunner();
    runner.startCoroutine( count() );

    // Dummy loop for the example
    new haxe.Timer(16).run = function() {
        // Customize how/when to update your coroutines
        var processor = CoroutineProcessor.of(runner);
        processor.updateEnterFrame();
        processor.updateTimer(haxe.Timer.stamp());
        processor.updateExitFrame();
    }
}
```
The above example will trace every 16 ms `0`, `1`, `2`, `3`, etc. You can try it with `haxe -lib coroutine --run Main.hx`.

Install
-----

To install the library, use `haxelib install coroutine` and compile your program with `-lib coroutine`.

Development Builds
-----

1. To clone the github repository, use `git clone https://github.com/dpomier/haxe-coroutine`

2. To tell haxelib where your development copy is installed, use `haxelib dev coroutine path/to/haxe-coroutine`

To return to release builds use `haxelib dev coroutine`
