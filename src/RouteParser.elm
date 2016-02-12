module RouteParser
  ( int, string, customParam, static, dyn1, dyn2, dyn3
  , parserMatcher, rawMatcher, match, router
  , mapMatcher, mapMatchers
  , Matcher, Param, Router
  ) where

{-| A typed router in Elm, with a nice DSL built on top of parser cominators
(see [README](https://github.com/etaque/elm-route-parser) for usage).

# DSL for simple cases
@docs int, string, customParam, static, dyn1, dyn2, dyn3

# Other route matcher builders
@docs parserMatcher, rawMatcher, mapMatcher, mapMatchers

# Because eventually you'll have to run the router
@docs match, router

# Types
@docs Matcher, Param, Router
-}

import Combine exposing (Parser, parse, end, andThen, map, andMap, many1, while, many, skip, maybe, Result (..))
import Combine.Char exposing (noneOf, char)
import Combine.Num as Num
import Combine.Infix exposing ((<$>), (<$), (<*), (*>), (<*>), (<|>))

import Maybe
import String
import List
import Dict exposing (Dict)

import RouteParser.Parser as Parser exposing (..)


{-| A single route parser -}
type Matcher route = M (String -> Maybe route)

{-| A param parser in a route -}
type Param a = P (Parser a)

{-| A router is composed of a route parser, and a path generator.
 -}
type alias Router route =
  { fromPath : String -> Maybe route
  , toPath : route -> String
  }


{-| Extract an Int param -}
int : Param Int
int =
  P Num.int


{-| Extract a String param -}
string : Param String
string =
  P stringParam


{-| Build a custom param extractor from a parser instance -}
customParam : Parser a -> Param a
customParam =
  P

{-| Build a route from a raw matcher function -}
rawMatcher : (String -> Maybe route) -> Matcher route
rawMatcher matcher =
  M matcher


{-| Build a route from a Parser instance -}
parserMatcher : Parser route -> Matcher route
parserMatcher parser =
  let
    matcher path = case parse parser path of
      (Done route, _) ->
        Just route
      _ ->
        Nothing
  in
    rawMatcher matcher


{-| Matcher for a static path.

    type Route = About
    matchers = [ static About "/about" ]

    match matchers "/about" == Just About
-}
static : route -> String -> Matcher route
static route path =
  parserMatcher <| route <$ (Combine.string path *> end)


{-| Matcher for a path with one dynamic param.

    type Route = Topic Int
    matchers = [ dyn1 Topic "/topic/" int "/edit" ]

    match matchers "/topic/1/edit" == Just (Topic 1)
-}
dyn1 : (a -> route) -> String -> Param a -> String -> Matcher route
dyn1 route s1 (P pa) s2 =
  parserMatcher <| route <$> (Combine.string s1 *> pa) <* Combine.string s2 <* end


{-| Matcher for a path with two dynamic params.

    type Route = SubTopic Int Int
    matchers = [ dyn2 SubTopic "/topic/" int "/" int "" ]

    match matchers "/topic/1/2" == Just (SubTopic 1 2)
-}
dyn2 : (a -> b -> route) -> String -> Param a -> String -> Param b -> String -> Matcher route
dyn2 route s1 (P pa) s2 (P pb) s3 =
  parserMatcher <| route <$> ((Combine.string s1 *> pa)) `andThen`
    (\r -> r <$> (Combine.string s2 *> pb <* Combine.string s3 <* end))


{-| Matcher for a path with three dynamic params.

    type Route = Something String String String
    matchers = [ dyn3 Something "/some/" string "/thing/" string "/here/" string "" ]

    match matchers "/some/cool/thing/must-be/here/i-guess" == Just (Something "cool" "must-be" "i-guess")
-}
dyn3 : (a -> b -> c -> route) -> String -> Param a -> String -> Param b -> String -> Param c -> String -> Matcher route
dyn3 route s1 (P pa) s2 (P pb) s3 (P pc) s4 =
  parserMatcher <| route <$> ((Combine.string s1 *> pa)) `andThen`
    (\r -> r <$> (Combine.string s2 *> pb)) `andThen`
    (\r -> r <$> (Combine.string s3 *> pc <* Combine.string s4 <* end))


{-| Map the result of the match -}
mapMatcher : (a -> b) -> Matcher a -> Matcher b
mapMatcher mapper (M matcher) =
  let
    newMatcher path = Maybe.map mapper (matcher path)
  in
    M newMatcher

{-| map a list of matchers from a route type to another route type.
Useful for subrouting, like delegating one of the routes to another type :

    -- global routing:

    type Route = Home | Admin AdminRoute

    matchers =
      [ static Home "/" ] ++ (mapMatchers Admin adminMatchers)

    -- can be delegated to a component without knowdedge of global routing:

    type AdminRoute = Dashboard | Users

    adminMatchers =
      [ static Dashboard "/admin", static Users "/users" ]
 -}
mapMatchers : (a -> b) -> List (Matcher a) -> List (Matcher b)
mapMatchers wrapper matchers =
  List.map (mapMatcher wrapper) matchers


{-| Given a list of matchers and a path, return the first successful match of the path.
-}
match : List (Matcher route) -> String -> Maybe route
match parsers url =
  List.foldl (matchUrl url) Nothing parsers


matchUrl : String -> Matcher route -> Maybe route -> Maybe route
matchUrl path (M matcher) maybeRoute =
  case maybeRoute of
    Just _ ->
      maybeRoute
    Nothing ->
      matcher path


{-| Full-featured router. A record with two properties:

* `fromPath` to maybe get the route from a path,
* `toPath`to build the path from the route, typically for links in the views.
 -}
router : List (Matcher route) -> (route -> String) -> Router route
router routeParsers pathGenerator =
  Router (match routeParsers) pathGenerator
