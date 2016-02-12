module Tests where

import ElmTest exposing (..)
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


all : Test
all =
  suite "all"
    [ test "static" <|
        assertMatch "/" Home

    , test "dyn1 on string" <|
        assertMatch "/foo/foo" (Foo "foo")

    , test "dyn2 on int with ignored slug" <|
        assertMatch "/bar/12-some-slug" (Bar 12)

    , test "dyn3 on string and int" <|
        assertMatch "/baz/1/a/2/b/3/c" (Baz 1 "2" 3)

    , test "incorrect int" <|
        assertNoMatch "/bar/2a-some-slug"
    ]


assertMatch : String -> Route -> Assertion
assertMatch path route =
  assertEqual (match matchers path) (Just route)


assertNoMatch : String -> Assertion
assertNoMatch path =
  assertEqual (match matchers path) Nothing

