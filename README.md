# Route parser for Elm, based on parser combinators

Based on [jasonzoladz's gist](https://gist.github.com/jasonzoladz/b68475f4f3eced50d88f), with a bit of sugar syntax.

## Usage

```elm
import RouteParser exposing (..)


type Route
  = Home
  | Foo String
  | Bar Int
  | Baz Int String Int


routeParsers : Parsers Route
routeParsers =
  [ static Home "/"
  , dyn1 Foo "/foo/" string ""
  , dyn2 (\id slug -> Bar id) "/bar/" int "-" string ""
  , dyn3 Baz "/baz/" int "/a/" string "/b/" int "/c"
  ]


match routeParsers "/" == Just Home
match routeParsers "/foo/foo" == Just (Foo "foo")
match routeParsers "/bar/12-some-slug" == Just (Bar 12)
match routeParsers "/baz/1/a/2/b/3/c" == Just (Baz 1 "2" 3)
```
