module RouteParser.Parser where

import String
import List
import Dict exposing (Dict)

import Combine exposing (..)
import Combine.Char as Char exposing (..)
import Combine.Num as Num
import Combine.Infix exposing (..)


stringParam : Parser String
stringParam =
  String.fromList <$> many1 (noneOf [ '/', '#', '?', '=', '&' ])


queryString : Parser (List (String, String))
queryString =
  Combine.string "?" *> Combine.sepBy (Combine.string "&") queryStringParam


queryStringParam : Parser (String, String)
queryStringParam =
  (,) `map` (stringParam <* Combine.string "=") `andMap` stringParam

