package tests.benchs;

import haxe.ds.GenericStack;
import haxe.Timer;
import utest.Assert;
import coroutine.Routine;
import coroutine.CoroutineRunner;
import tests.Tests.println;

class Starting implements utest.ITest {

	public function new () { }

	#if (!cpp && !php && !lua)
	@:analyzer(ignore)
	#end
	public function testStarting () {

		var targetIteration = 10000;
		var pool = new GenericStack<Routine>();
		for(_ in 0...targetIteration + 1)
			pool.add(getCoroutine());

		var cr = new CoroutineRunner();
		var ch = new CoroutineProcessor(cr);
		var startTime = Timer.stamp();
		var numSamples = 0;
		do {

			@:inline cr.startCoroutine( pool.pop() );

		} while(++numSamples < targetIteration);
		var endTime = Timer.stamp();
		var mu = (endTime - startTime) * 1000000.;
		println('Bench: starting = ${mu / numSamples} (μs)');

		utest.Assert.isTrue(true);
	}

	static function getCoroutine () {
		@yield return RoutineInstruction.WaitNextFrame;
	}
}