package coroutine._macro;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class RoutineBuilder {

    static function init () {
        yield.parser.Parser.parseOnImport("coroutine.Routine");
        yield.parser.Parser.parseOnImport("coroutine.Routine.RoutineInstruction");
        yield.parser.Parser.onYield(onYield);
    }

    static function onYield (e:Expr, t:Null<ComplexType>):Null<Expr>
        return switch t {
            case (macro:coroutine.Routine.RoutineInstruction):
                transformInstruction(e);
                null;
            case _:
                null;
        }

    static function transformInstruction (e:Expr):Void
        switch e {
            case (macro ($w)):
                transformInstruction(w);
            case { expr: expr, pos: pos }:
                e.expr = (macro switch (${{ expr: expr, pos: pos }}) {
                    case null: (coroutine.Routine.RoutineInstruction.WaitNextFrame : coroutine.Routine.RoutineInstruction);
                    case v: (v : coroutine.Routine.RoutineInstruction);
                }).expr;
        }

}
#end