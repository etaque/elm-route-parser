module RouteParser.Parser exposing (..)

import String
import Combine exposing (..)
import Combine.Char as Char exposing (..)
import Combine.Infix exposing (..)


stringParam : Parser String
stringParam =
  String.fromList <$> many1 (noneOf [ '/', '#', '?', '=', '&' ])


queryString : Parser (List ( String, String ))
queryString =
  Combine.string "?" *> Combine.sepBy (Combine.string "&") queryStringParam


queryStringParam : Parser ( String, String )
queryStringParam =
  (,) `map` (stringParam <* Combine.string "=") `andMap` stringParam
