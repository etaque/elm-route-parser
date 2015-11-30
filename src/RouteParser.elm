module RouteParser (intParam, stringParam, static, dyn1, dyn2, dyn3, match, Url, Parsers) where

{-| A path parser for your web app routing, base on parser combinators.

# Types
@docs Url, Parsers

# Path segment parsing
@docs intParam, stringParam

# Full path parsing
@docs static, dyn1, dyn2, dyn3

# Matching a path on a list of parsers
@docs match
-}

import Combine exposing (Parser, string, parse, end, andThen, many1, while, many, skip, maybe, Result (..))
import Combine.Char exposing (noneOf, char)
import Combine.Num exposing (int)
import Combine.Infix exposing ((<$>), (<$), (<*), (*>), (<*>), (<|>))

import Maybe
import String
import List


{-| A String path -}
type alias Url = String


{-| A list of parsers -}
type alias Parsers route = List (Parser route)


{-| Extract an Int param -}
intParam : Parser Int
intParam =
  int


{-| Extract a String param -}
stringParam : Parser String
stringParam =
  String.fromList <$> many1 (noneOf [ '/', '#', '?' ])


{-| Parser for a static path

    type Route = About
    routes = [ static About "/about" ]

    match routes "/about" == Just About
-}
static : route -> String -> Parser route
static route path =
  route <$ (string path *> end)


{-|  Parser for a path with one dynamic segment

    type Route = Topic Int
    routes = [ dyn1 Topic "/topic/" intParam "/edit" ]

    match routes "/topic/1/edit" == Just (Topic 1)
-}
dyn1 : (a -> route) -> String -> Parser a -> String -> Parser route
dyn1 route s1 pa s2 =
  route <$> (string s1 *> pa) <* string s2 <* end


{-|  Parser for a path with two dynamic segments

    type Route = SubTopic Int Int
    routes = [ dyn2 SubTopic "/topic/" intParam "/" intParam "" ]

    match routes "/topic/1/2" == Just (SubTopic 1 2)
-}
dyn2 : (a -> b -> route) -> String -> Parser a -> String -> Parser b -> String -> Parser route
dyn2 route s1 pa s2 pb s3 =
  route <$> ((string s1 *> pa)) `andThen`
    (\r -> r <$> (string s2 *> pb <* string s3 <* end))


{-|  Parser for a path with three dynamic segments

    type Route = Something String String String
    routes = [ dyn3 Something "/some/" stringParam "/thing/" stringParam "/here/" stringParam "" ]

    match routes "/some/cool/thing/must-be/here/i-guess" == Just (Something "cool" "must-be" "i-guess")
-}
dyn3 : (a -> b -> c -> route) -> String -> Parser a -> String -> Parser b -> String -> Parser c -> String -> Parser route
dyn3 route s1 pa s2 pb s3 pc s4 =
  route <$> ((string s1 *> pa)) `andThen`
    (\r -> r <$> (string s2 *> pb)) `andThen`
    (\r -> r <$> (string s3 *> pc <* string s4 <* end))



{-| Given a list of parsers and a path, find the first parser matching the path
-}
match : Parsers route -> Url -> Maybe route
match parsers url =
  List.foldl (matchUrl url) Nothing parsers


matchUrl : Url -> Parser route -> Maybe route -> Maybe route
matchUrl url parser maybeRoute =
  case maybeRoute of
    Just _ ->
      maybeRoute
    Nothing ->
      case parse parser url of
        (Done route, _) ->
          Just route
        _ ->
          Nothing
