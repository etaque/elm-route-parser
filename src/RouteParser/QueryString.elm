module RouteParser.QueryString (parse) where

{-| Tools for query string parsing and extraction

@docs parse
-}


import Dict exposing (Dict)
import Combine exposing (Result(..))

import RouteParser.Parser as Parser


type alias QueryString =
  Dict String (List String)


{-| Parse a query string as a `Dict String (List String)`. -}
parse : String -> QueryString
parse s =
  case Combine.parse Parser.queryString s of
    (Done list, _) ->
      fromList list
    _ ->
      Dict.empty


fromList : List (String, String) -> QueryString
fromList items =
  let
    addItem (key, value) dict =
      let
        keyValues = Dict.get key dict |> Maybe.withDefault []
      in
        Dict.insert key (value :: keyValues) dict
  in
    List.foldr addItem Dict.empty items
