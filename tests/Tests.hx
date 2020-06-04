package tests;
import utest.Runner;
import utest.ui.Report;

class Tests {

	static function main () {

		var r = new Runner();

		r.addCase(new tests.basics.YieldTests());
		r.addCase(new tests.basics.NextFrameTests());
		r.addCase(new tests.basics.WaitDelayTests());
		r.addCase(new tests.basics.SubroutineTests());
		r.addCase(new tests.basics.WaitWhileTests());

		r.addCase(new tests.benchs.Starting());
		r.addCase(new tests.benchs.WaitNextFrame());
		r.addCase(new tests.benchs.WaitRoutine());

		Report.create(r);
		r.run();

	}

	public static inline function println (v:String)
		#if travix
		  travix.Logger.println(v);
		#elseif (flash || air || air3)
		  flash.Lib.trace(v);
		#elseif (sys || nodejs)
		  Sys.println(v);
		#else
		  trace(v);
		#end

}