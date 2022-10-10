module IR.Expr exposing (..)

import IR.Spec as Spec exposing (Spec)



-- TODO: perhaps decorate every tag with a spec


type Expr
    = Variable String
    | Lambda Linear String Expr
    | Apply Expr Expr
    | Unborrow String Expr
    | Annotation Spec Expr


type alias Linear =
    Maybe Bool


toString : Expr -> String
toString expr =
    case expr of
        Variable name ->
            name

        Lambda (Just True) name body ->
            "(*" ++ name ++ " => " ++ toString body ++ ")"

        Lambda _ name body ->
            "(" ++ name ++ " -> " ++ toString body ++ ")"

        Apply function argument ->
            "(" ++ toString function ++ " " ++ toString argument ++ ")"

        Unborrow name body ->
            "unborrow " ++ name ++ " in " ++ toString body

        Annotation spec (Lambda _ name body) ->
            -- WTF is this? I don't remember
            "(" ++ name ++ " [" ++ Spec.toString spec ++ "] -> " ++ toString body ++ ")"

        Annotation spec expr_ ->
            "<" ++ Spec.toString spec ++ ">" ++ toString expr_