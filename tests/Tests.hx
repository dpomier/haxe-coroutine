package tests;
import utest.Runner;
import utest.ui.Report;
import tests.basics.YieldTests;
import tests.basics.NextFrameTests;

class Tests {

    static function main () {

        var r = new Runner();

        r.addCase(new YieldTests());
        r.addCase(new NextFrameTests());

        Report.create(r);
        r.run();

    }

}