#!/bin/bash

cd test
elm-make --yes
elm-test TestRunner.elm
