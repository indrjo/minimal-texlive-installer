#!/usr/bin/env sh

set -e

if [ `uname -o` == Android ]
  then here=$PREFIX/bin
  else here=~/.local/bin
fi
[ -d $here ] || mkdir -p $here
cp ./flytex.py $here/flytex
chmod u+x $here/flytex

