package tests.benchs;

import haxe.Timer;
import utest.Assert;
import coroutine.Routine;
import coroutine.CoroutineProcessor;
import tests.Tests.println;

class WaitNextFrame implements utest.ITest {

    public function new () { }

    @:analyzer(ignore)
    public function testWaitNextFrame () {

        var targetIteration = 10000;

        var ch = new CoroutineProcessor();
        ch.startCoroutine( getWaitNextFrameLoop() );
        
        var startTime = Timer.stamp();
        var numSamples = 0;
        /* inline */ ch.updateEnterFrame();
        do {

            /* inline */ ch.updateEnterFrame();

        } while(++numSamples < targetIteration);
        var endTime = Timer.stamp();
        var mu = (endTime - startTime) * 1000000.;
        println('Bench: wait next frame = ${mu / numSamples} (μs)');
        utest.Assert.isTrue(true);

    }

    static function getWaitNextFrameLoop () {
        while (true)
            @yield return RoutineInstruction.WaitNextFrame;
    }

}