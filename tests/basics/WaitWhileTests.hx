package tests.basics;

import utest.Assert;
import coroutine.Routine;
import coroutine.Routine.RoutineInstruction.*;
import coroutine.CoroutineProcessor;

class WaitWhileTests implements utest.ITest {

    var ch = new CoroutineProcessor();

    var counter = 0;

    public function new () {
        
    }

    public function testWhile () {

        ch.startCoroutine( routine() );

        for (i in 0...16) {

            ch.updateEnterFrame();
            ch.updateTimer( haxe.Timer.stamp() );
            ch.updateExitFrame();
        }

        Assert.equals(5, counter);
    }

    function isActive ():Bool {

        return ++counter < 5;
    }

    function routine () {

        @yield return WaitWhile( isActive );

    }

}