package coroutine;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

#if (macro || display)
class RoutineBuilder {

    private static function init () {

        trace("INIT");

        yield.parser.Parser.parseOnImport("coroutine.Routine");
        yield.parser.Parser.parseOnImport("coroutine.RoutineInstruction");
        yield.parser.Parser.onTypeYielded("coroutine.RoutineInstruction", buildReturnedExpression, false);

    }

    private static function buildReturnedExpression (e:Expr):Null<Expr> {
        
        return switch (removeParenthesis(e).expr) {
            case EConst(CIdent("null")): 
                trace("PARSE NULL");
                macro (cast 0:coroutine.RoutineInstruction);
            case _: 
                trace("KEEP", haxe.macro.ExprTools.toString(e));
                e;
    //         case (macro WaitNextFrame)
    //            | (macro RoutineInstruction.WaitNextFrame)
    //            | (macro coroutine.RoutineInstruction.WaitNextFrame):
    //            return macro cast 0;
    //         case (macro WaitEndOfFrame)
    //            | (macro RoutineInstruction.WaitEndOfFrame)
    //            | (macro coroutine.RoutineInstruction.WaitEndOfFrame):
    //            return macro cast 1;
    //         case (macro WaitDelay(_seconds))
    //            | (macro RoutineInstruction.WaitDelay(_seconds))
    //            | (macro coroutine.RoutineInstruction.WaitDelay(_seconds)):
               
    //             var ms:ExprOf<Int> = switch (removeParenthesis(_seconds).expr) {
    //                 case EConst(CFloat(__v)): macro $v{2 + Std.int(1000 * Std.parseFloat(__v))};
    //                 case EConst(CInt(__v)): macro $v{2 + 1000 * Std.parseInt(__v)};
    //                 case other: macro 2 + Std.int(1000 * $other);
    //             };

    //             ms.pos = _seconds.pos;

    //             return macro cast $ms;

    //         case (macro WaitDelay(_routine))
    //            | (macro RoutineInstruction.WaitDelay(_routine))
    //            | (macro coroutine.RoutineInstruction.WaitDelay(_routine)):
               
    //             return macro {
    //                 coroutine.CoroutineSystem.waitingRoutineCounter--;
    //                 coroutine.CoroutineSystem.waitingRoutineIds.set(coroutine.CoroutineSystem.waitingRoutineCounter, $_routine);
    //                 coroutine.CoroutineSystem.waitingRoutineCounter;
    //             };

        }

    }

    private static function removeParenthesis (e:Expr):Expr {
        
        return switch (e.expr) {
            case EParenthesis(_e): removeParenthesis(_e);
            case _: e;
        };

    }

}
#end