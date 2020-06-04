package tests.basics;

import utest.Assert;
import coroutine.CoroutineRunner;
import coroutine.Routine.RoutineInstruction.*;

class NextFrameTests implements utest.ITest {

	public function new () {
		
	}

	public function testWorkflow () {

		var obj = { v: [] };

		var cr = new CoroutineRunner();
		var ch = new CoroutineProcessor(cr);

		cr.startCoroutine( returnA(obj) );
		Assert.equals(1, obj.v[0]);
		Assert.equals(1, obj.v.length);

		cr.startCoroutine( returnB(obj) );
		Assert.equals(10, obj.v[1]);
		Assert.equals(2, obj.v.length);

		for (i in 0...6) {

			ch.updateEnterFrame();
			ch.updateTimer( haxe.Timer.stamp() );

			switch (i) {
				case 0:
					Assert.equals(4, obj.v.length);
					Assert.equals(22, obj.v[2] + obj.v[3]);
				case 1:
					Assert.equals(6, obj.v.length);
					Assert.equals(33, obj.v[4] + obj.v[5]);
				case _:
					Assert.equals(6, obj.v.length);
			}

			ch.updateExitFrame();
		}
	}

	function returnA (obj:{v:Array<Int>}) {

		obj.v.push(1);
		@yield return WaitNextFrame;

		obj.v.push(2);
		@yield return WaitNextFrame;

		obj.v.push(3);
	}

	function returnB (obj:{v:Array<Int>}) {
		
		obj.v.push(10);
		@yield return WaitNextFrame;

		obj.v.push(20);
		@yield return null;

		obj.v.push(30);
	}

}