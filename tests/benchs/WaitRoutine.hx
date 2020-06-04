package tests.benchs;

import haxe.ds.GenericStack;
import haxe.Timer;
import utest.Assert;
import coroutine.Routine;
import coroutine.CoroutineRunner;
import tests.Tests.println;

class WaitRoutine implements utest.ITest {

	public function new () { }

	#if (!cpp && !php && (!lua || haxe_ver >= 4.100)) // See https://github.com/HaxeFoundation/haxe/issues/8767
	@:analyzer(ignore)
	#end
	public function testWaitRoutine () {

		var targetIteration = 10000;
		var pool = new GenericStack<Routine>();
		for(_ in 0...targetIteration + 1)
			pool.add(getCoroutine());

		var cr = new CoroutineRunner();
		var ch = new CoroutineProcessor(cr);
		cr.startCoroutine( getWaitRoutine(pool) );
		
		var startTime = Timer.stamp();
		var numSamples = 0;
		do {

			@:inline ch.updateEnterFrame();

		} while(++numSamples < targetIteration);
		var endTime = Timer.stamp();
		var mu = (endTime - startTime) * 1000000.;
		println('Bench: wait routine = ${mu / numSamples} (μs)');
		utest.Assert.isTrue(true);
	}

	static function getWaitRoutine (pool:GenericStack<Routine>) {
		while( true )
			@yield return RoutineInstruction.WaitRoutine( pool.pop() );
	}

	static function getCoroutine () {
		@yield return RoutineInstruction.WaitNextFrame;
	}
}