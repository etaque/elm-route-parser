module Tests where

import Dict exposing (Dict)
import ElmTest exposing (..)

import RouteParser exposing (..)
import RouteParser.QueryString as QueryString


type Route
  = Home
  | Foo String
  | Bar Int
  | Baz Int String Int
  | Taz (List (String, String))


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
    [ pathSuite, queryStringSuite ]


pathSuite : Test
pathSuite =
  suite "path"

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
  assertEqual (Just route) (match matchers path)


assertNoMatch : String -> Assertion
assertNoMatch path =
  assertEqual Nothing (match matchers path)


queryStringSuite : Test
queryStringSuite =
  suite "query string"

    [ test "query string with list" <|
        assertEqual [("aaa", ["1"]), ("bb", ["2", "3"])] (QueryString.parse "?aaa=1&bb=2&bb=3" |> Dict.toList)

    , test "empty query string" <|
        assertEqual [] (QueryString.parse "" |> Dict.toList)

    , test "missing values" <|
        assertEqual [] (QueryString.parse "?a=&b=" |> Dict.toList)
    ]

