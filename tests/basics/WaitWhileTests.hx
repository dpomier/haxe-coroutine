package tests.basics;

import utest.Assert;
import coroutine.Routine;
import coroutine.Routine.RoutineInstruction.*;
import coroutine.CoroutineRunner;

class WaitWhileTests implements utest.ITest {

	var cr = new CoroutineRunner();
	var ch:CoroutineProcessor;

	var counter = 0;

	public function new () {
		ch = new CoroutineProcessor(cr);
	}

	public function testWhile () {

		cr.startCoroutine( routine() );

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