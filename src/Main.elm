module Main exposing (..)

import Browser
import Html exposing (text)
import Lang.Canonical.Expr exposing (Expr(..))
import Lang.Canonical.Type as Type exposing (Type(..))
import Lang.Infer as Infer exposing (Return(..))
import Lang.Infer.Error exposing (Error(..))
import Lang.Infer.State as State


main =
    let
        -- expr =
        --     Lam "s" (\s -> Lam "z" (\z -> App s (App s z)))
        expr =
            Lam "f" (\f -> Lam "g" (\g -> Lam "a" (\a -> App g (App f a))))

        -- expr =
        --     Lam "f" (\f -> Lam "a" (\a -> Lam "b" (\b -> App (App f a) b)))
        -- ann =
        --     TArr (TArr (TVar False 0) (TArr (TVar False 1) (TVar False 2))) (TArr (TVar False 0) (TArr (TVar False 1) (TVar False 2)))
        -- expr_ =
        --     Ann ann expr
        _ =
            case Infer.infer expr State.empty of
                Return thisT state ->
                    let
                        _ =
                            Debug.log "type" (Type.toString thisT)

                        _ =
                            Debug.log "state" state
                    in
                    ""

                Throw (Error msg) ->
                    Debug.log "error" msg
    in
    Browser.sandbox { init = (), update = always (always ()), view = always (text "") }


ssz : (b -> b) -> b -> b
ssz s z =
    s (s z)


compose : (a -> b) -> (b -> c) -> a -> c
compose =
    (>>)


apply2 : (b -> c -> a) -> b -> c -> a
apply2 f a b =
    f a b
