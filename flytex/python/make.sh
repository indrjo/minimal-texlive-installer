#!/usr/bin/env sh

set -e

# You can install the *python flyex* on Android too.
if [ `uname -o` == Android ]
  then here=$PREFIX/bin
  else here=~/.local/bin
fi
[ -d $here ] || mkdir -p $here
cp ./flytex.py $here/flytex
chmod u+x $here/flytex

