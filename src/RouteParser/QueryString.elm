module RouteParser.QueryString (QueryString, parse) where

{-| Tools for query string parsing and extraction

@docs QueryString, parse
-}


import Dict exposing (Dict)
import Combine exposing (Result(..))

import RouteParser.Parser as Parser


{-| A parsed query string is a Dict of param names to param value list. -}
type alias QueryString =
  Dict String (List String)


{-| Parse a query string. Parsed string must include the leading "?" char. -}
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
