# Elm Route Parser

A typed route parser in Elm, with a nice DSL built on top of parser combinators. Designed to work well with `path` or `hash` signals from [elm-history](http://package.elm-lang.org/packages/elm-community/elm-history/latest): just map an action on it and do a `RouteParser.match` to update your current route, then use this route to render the right view.

    elm package install etaque/elm-route-parser

Note: see [elm-transit-router](https://github.com/etaque/elm-transit-router) for a full featured SPA router compatible with this package.

Under the hood, it's just a list of matchers `String -> Maybe Route`, and the first match wins. For that, there is a DSL tailored to mimic path shapes, ensuring typesafety with the power of parser combinators without the surface complexity:

```elm
"/some/" int "/path"
```

If the dynamic param isn't parsable as an int, it won't match as an acceptable path for this route:

```elm
"/some/1/path" -- match!
"/some/wrong/path" -- no match
```


Note that you can create and use custom param parsers, and custom matchers.

A query string parser is also available under `RouteParser.QueryString` module: `parse : String -> Dict String (List String)`.

## Usage

### DSL

Example:

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

-- static
match matchers "/" == Just Home

-- dyn1
match matchers "/foo/foo" == Just (Foo "foo")

-- dyn2
match matchers "/bar/12-some-slug" == Just (Bar 12)
match matchers "/bar/hey-some-slug" == Nothing

-- dyn3
match matchers "/baz/1/a/2/b/3/c" == Just (Baz 1 "2" 3)
```


### Custom matchers

If the DSL isn't enough for your needs, you can also use one of those escape hatches to build a custom matcher:

* `customParam` to build a param extractor from a Parser instance, so it can be used with the DSL ;
* `parserMatcher`, takes a `Parser Route` instance ;
* `rawMatcher`, takes a `String -> Maybe Route` function.

See [elm-combine](http://package.elm-lang.org/packages/Bogdanp/elm-combine/latest) for more information on parsers.


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
      [ static Dashboard "/admin", static Users "/admin/users" ]
```

### Reverse routing

The reverse router has yet to be written manually:

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

- [x] Tests
- [ ] Query string parsing


## Credits

* Based on an original idea of [jasonzoladz](https://gist.github.com/jasonzoladz/b68475f4f3eced50d88f),
* Built with [elm-combine](http://package.elm-lang.org/packages/Bogdanp/elm-combine/latest), an excellent parser combinator library.
