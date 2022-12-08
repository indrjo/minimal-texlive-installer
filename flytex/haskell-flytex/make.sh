#!/usr/bin/env sh

here=~/.local/bin
[ -d $here ] || mkdir -p $here
ghc -Wall -O2 -o $here/flytex ./flytex.hs

