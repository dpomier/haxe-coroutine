package tests.basics;

import haxe.Timer;
import utest.Assert;
import coroutine.Routine;
import coroutine.Routine.RoutineInstruction.WaitDelay;
import coroutine.CoroutineRunner;

class WaitDelayTests implements utest.ITest {

    var cr = new CoroutineRunner();
    var ch:CoroutineProcessor;

    public function new () {
        ch = new CoroutineProcessor(cr);
    }

    function loop () {

        ch.updateEnterFrame();
        ch.updateTimer( haxe.Timer.stamp() );
        ch.updateExitFrame();

        Timer.delay(loop, 16);
    }

    @:timeout(700)
    public function testDelay (async:utest.Async) {

        loop();

        var obj = { value: 0 };
        cr.startCoroutine( delay(obj) );

        var a = obj.value;
        var b = -1;
        var c = -1;
        
        Timer.delay(function () {
            b = obj.value;
        }, 300);

        Timer.delay(function () {
            c = obj.value;
            
            Assert.equals(1, a);
            Assert.equals(2, b);
            Assert.equals(3, c);

            async.done();
        }, 550);
    }

    function delay (obj:{ value:Int }):Routine {
        
        obj.value = 1;
        @yield return WaitDelay(0.25);

        obj.value = 2;
        @yield return WaitDelay(0.25);

        obj.value = 3;
    }

}