package tests.basics;

import coroutine.Routine;
import coroutine.Routine.RoutineInstruction.*;
import utest.Assert;
import coroutine.CoroutineRunner;

class SubroutineTests implements utest.ITest {

	var cr = new CoroutineRunner();
	var ch:CoroutineProcessor;

	public function new () {
		ch = new CoroutineProcessor(cr);
	}

	public function testSubroutine () {

		var report:Array<Int> = [];
		cr.startCoroutine( routine(report) );

		Assert.equals([1].toString(), report.toString());
		
		ch.updateEnterFrame();
		Assert.equals([1,2,10].toString(), report.toString());
		ch.updateExitFrame();
		Assert.equals([1,2,10].toString(), report.toString());
		

		ch.updateEnterFrame();
		Assert.equals([1,2,10,11].toString(), report.toString());
		ch.updateExitFrame();
		Assert.equals([1,2,10,11,12].toString(), report.toString());
		

		ch.updateEnterFrame();
		Assert.equals([1,2,10,11,12,13,3].toString(), report.toString());
		ch.updateExitFrame();
		Assert.equals([1,2,10,11,12,13,3].toString(), report.toString());

	}

	function routine (obj:Array<Int>) {
		obj.push(1);
		@yield return RoutineInstruction.WaitNextFrame;
		obj.push(2);
		@yield return WaitRoutine( subroutine(obj) );
		obj.push(3);
	}

	function subroutine (obj:Array<Int>) {
		obj.push(10);
		@yield return null;
		obj.push(11);
		@yield return RoutineInstruction.WaitEndOfFrame;
		obj.push(12);
		@yield return null;
		obj.push(13);
	}

	public function testOverflowProof () {

		var routine:Routine = (function () {
			@yield return WaitNextFrame;
		})();

		cr.startCoroutine( routine );
		cr.startCoroutine( routine );

		Assert.pass();

	}
}