module RouteParser.Parser exposing (..)

import String
import Combine exposing (..)
import Combine.Char as Char exposing (..)


stringParam : Parser s String
stringParam =
    String.fromList <$> many1 (noneOf [ '/', '#', '?', '=', '&' ])


queryString : Parser s (List ( String, String ))
queryString =
    Combine.string "?" *> Combine.sepBy (Combine.string "&") queryStringParam


queryStringParam : Parser s ( String, String )
queryStringParam =
    (map (,) (stringParam <* Combine.string "="))
        |> andMap stringParam
