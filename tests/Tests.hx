package tests;
import utest.Runner;
import utest.ui.Report;
import tests.basics.YieldTests;
import tests.basics.NextFrameTests;
import tests.basics.WaitDelayTests;
import tests.basics.SubroutineTests;

class Tests {

    static function main () {

        var r = new Runner();

        r.addCase(new YieldTests());
        r.addCase(new NextFrameTests());
        // r.addCase(new WaitDelayTests());
        r.addCase(new SubroutineTests());

        Report.create(r);
        r.run();

    }

}