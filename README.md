# Elm Route Parser

A typed router in Elm, with a nice DSL built on top of parser cominators.


## Usage

### DSL

```elm
import RouteParser exposing (..)

type Route
  = Home
  | Foo String
  | Bar Int
  | Baz Int String Int

matchers : List (Matcher Route)
matchers =
  [ static Home "/"
  , dyn1 Foo "/foo/" string ""
  , dyn2 (\id slug -> Bar id) "/bar/" int "-" string ""
  , dyn3 Baz "/baz/" int "/a/" string "/b/" int "/c"
  ]

match matchers "/" == Just Home
match matchers "/foo/foo" == Just (Foo "foo")
match matchers "/bar/12-some-slug" == Just (Bar 12)
match matchers "/baz/1/a/2/b/3/c" == Just (Baz 1 "2" 3)
```

### Custom matchers

If the DSL isn't enough for your needs, you can also use one of those escape hatches to build a custom matcher:

* `customParam` to build a param extractor from a Parser instance, so it can be used with the DSL ;
* `parserMatcher`, takes a `Parser Route` instance ;
* `rawMatcher`, takes a `String -> Maybe Route` function.

See [Elm-Combine](http://package.elm-lang.org/packages/Bogdanp/elm-combine/latest) for more information on parsers.


### Route matching delegation

Use `mapMatchers` to delegate a bunch of routes to a component:

```elm
    -- global routing:

    type Route = Home | Admin AdminRoute

    matchers =
      [ static Home "/" ] ++ (mapMatchers Admin adminMatchers)

    -- can be delegated to a component without knowdedge of global routing:

    type AdminRoute = Dashboard | Users

    adminMatchers =
      [ static Dashboard "/admin", static Users "/users" ]
```

### Reverse routing

The reverse routeur has yet to be written manually:

```elm

toPath : Route -> String
toPath route =
  case route of
    Home -> "/"
    Foo s -> "/foo/" ++ s
    Bar i -> "/bar/" ++ (toString i)
    Baz i s j -> "/baz/" ++ (toString i) ++ "/a/" ++ s ++ (toString j) ++ "/c"
```

Glad to take any PR on that part, there is room for improvement.


## Todo

* Tests
* Query string parsing


## Credits

* Based on an original idea of [jasonzoladz](https://gist.github.com/jasonzoladz/b68475f4f3eced50d88f),
* Built with [Elm-Combine](http://package.elm-lang.org/packages/Bogdanp/elm-combine/latest), an excellent parser combinator library.
