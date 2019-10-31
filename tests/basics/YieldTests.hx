package tests.basics;

import utest.Assert;

@:yield
class YieldTests implements utest.ITest {

    public function new () {
        
    }

    public function testBasicYield () {

        var it = basicYield();
        Assert.isTrue(it.hasNext());
        Assert.equals("Hello", it.next());
        Assert.equals("World", it.next());
        Assert.isFalse(it.hasNext());
    }

    function basicYield () {

        @yield return "Hello";
        @yield return "World";
    }

}