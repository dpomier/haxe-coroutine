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

    static function onYield (e:Expr, t:Null<ComplexType>):Null<Expr> {

        return switch t {
            case macro:coroutine.Routine.RoutineInstruction:
                buildInstruction(e, true);
            case _:
                null;
        }
    }

    static function buildInstruction (e:Expr, typed:Bool):Null<Expr> {

        return switch e {

            case null:

                null;
            
            case (macro ($w)):

                buildInstruction(w, typed);

            case macro null if( typed ):

                macro (coroutine.Routine.RoutineInstruction.WaitNextFrame : coroutine.Routine.RoutineInstruction);

            case _:

                null;
        }
    }

}
#end