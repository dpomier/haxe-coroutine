package coroutine._;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import yield.parser.Parser;

class RoutineBuilder {

    static function init () {
        Parser.parseOnImport("coroutine.Routine");
        Parser.parseOnImport("coroutine.Routine.RoutineInstruction");
        Parser.onYield(onYield);
    }

    static function onYield (e:Expr, t:Null<ComplexType>):Null<YieldedExpr> {

        if (Context.defined("display"))
            return null;

        var expr = switch [t, e] {

            case [_,
                  { expr: EParenthesis(w), pos: _ }
                | { expr: EMeta(_,w), pos: _ }
                | { expr: EUntyped(w), pos: _ }
                | { expr: ECast(w,_), pos: _ }
                | { expr: ECheckType(w,_), pos: _ }
                | { expr: EBlock([w]), pos: _ }]:

                return onYield(w, t);

            case [macro:coroutine.Routine.RoutineInstruction, macro null]:
                macro coroutine._.RI.fromNull();

            case [_,(macro WaitNextFrame) | (macro RoutineInstruction.WaitNextFrame) | (macro coroutine.Routine.RoutineInstruction.WaitNextFrame)]:
                macro coroutine._.RI.waitNext();

            case [_,(macro WaitEndOfFrame) | (macro RoutineInstruction.WaitEndOfFrame) | (macro coroutine.Routine.RoutineInstruction.WaitEndOfFrame)]:
                macro coroutine._.RI.waitEnd();

            case [_,(macro WaitDelay($s)) | (macro RoutineInstruction.WaitDelay($s)) | (macro coroutine.Routine.RoutineInstruction.WaitDelay($s))]:
                macro coroutine._.RI.waitDelay($s);

            case [_,(macro WaitRoutine($r)) | (macro RoutineInstruction.WaitRoutine($r)) | (macro coroutine.Routine.RoutineInstruction.WaitRoutine($r))]:
                macro coroutine._.RI.waitRoutine($r);

            case [_,(macro WaitWhile($f)) | (macro RoutineInstruction.WaitWhile($f)) | (macro coroutine.Routine.RoutineInstruction.WaitWhile($f))]:
                macro coroutine._.RI.waitWhile($f);

            case [macro:coroutine.Routine.RoutineInstruction, e]:
                macro @:mergeBlock {
                    var v = ${{ expr: e.expr, pos: e.pos }};
                    if ((cast v:Null<Any>) != null) // makes the analyzer happy with Haxe 4.0.5 and older (https://github.com/HaxeFoundation/haxe/issues/9200)
                        coroutine._.RI.fromRoutineInstruction(v);
                    else
                        coroutine._.RI.fromNull();
                };

            case _:
                return null;
        }

        e.expr = expr.expr; // doesn't trigger reparsing

        return {
            type: macro:coroutine._.RI
        }
    }
}
#end