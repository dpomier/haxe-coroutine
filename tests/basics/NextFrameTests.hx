package tests.basics;
import utest.Assert;
import coroutine.CoroutineSystem;
import coroutine.RoutineInstruction;

class NextFrameTests {

    private var assertCount:Int;

    public function new () {
        
    }

    public function testWorkflow () {

        var obj = { v: [] };

        var ch = new CoroutineSystem();

        ch.startCoroutine( returnNull(obj) );
        Assert.equals(1, obj.v[0]);
        Assert.equals(1, obj.v.length);

        ch.startCoroutine( returnEnum(obj) );
        Assert.equals(10, obj.v[1]);
        Assert.equals(2, obj.v.length);

        for (i in 0...6) {

            ch.updateCoroutineEnterFrame();

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

            ch.updateCoroutineExitFrame();
        }
    }

    function returnNull (obj:{v:Array<Int>}) {

        obj.v.push(1);
        @yield return null;

        obj.v.push(2);
        @yield return WaitNextFrame;

        obj.v.push(3);
    }

    function returnEnum (obj:{v:Array<Int>}) {
        
        obj.v.push(10);
        @yield return WaitNextFrame;

        obj.v.push(20);
        @yield return null;

        obj.v.push(30);
    }

}