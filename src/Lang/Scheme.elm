module Lang.Scheme exposing
    ( Scheme, substitute, freeVariables
    , Environment
    , freshInt, freshTypevar, instantiate, generalize
    )

{-|


#

@docs Scheme, substitute, freeVariables
@docs Environment
@docs freshInt, freshTypevar, instantiate, generalize

-}

import Dict exposing (Dict)
import Lang.Monad as Lang
import Lang.Type as Type exposing (Type(..))
import Set exposing (Set)


{-| Generates an int one greater than the last.
-}
freshInt : Lang.Monad Int
freshInt =
    Lang.advance (\state -> ( Ok state, state + 1 ))


{-| freshInt wrapped in TAny
-}
freshTypevar : Lang.Monad Type
freshTypevar =
    Lang.map TAny freshInt


{-| A type scheme represents a variable definition, for example a named function.
When the variable is used, the scheme must be converted into a concrete type.
The listed type variables are the ones that the type is generic over. It may
contain others that represent for example types of things defined higher up.
-}
type alias Scheme =
    ( List Int, Type )


{-| Converts a scheme into a concrete type by swapping the generic type
variables for fresh ones.
-}
instantiate : Scheme -> Lang.Monad Type
instantiate ( vars, t ) =
    List.map (\v -> Lang.map (Tuple.pair v) freshTypevar) vars
        |> Lang.combine
        |> Lang.map Dict.fromList
        |> Lang.map (\s -> Type.substitute s t)


{-| Holds all names defined in outer scopes.
-}
type alias Environment =
    Dict String Scheme


{-| Applies a substitution on a type scheme without touching the generic type vars
-}
substitute : Type.Substitution -> Scheme -> Scheme
substitute s ( vars, t ) =
    ( vars, Type.substitute (List.foldl Dict.remove s vars) t )


{-| Converts a type into a type scheme that is generic over all the type variables
in the type not coming from the environment.
-}
generalize : Type -> Environment -> Scheme
generalize t env =
    let
        inEnv =
            List.map freeVariables (Dict.values env)
                |> List.foldl Set.union Set.empty

        inType =
            Type.variables t

        generic =
            Set.diff inType inEnv
    in
    ( Set.toList generic, t )


{-| Variables that are not bound by the type scheme.
-}
freeVariables : Scheme -> Set Int
freeVariables ( generic, t ) =
    Set.diff (Type.variables t) (Set.fromList generic)
