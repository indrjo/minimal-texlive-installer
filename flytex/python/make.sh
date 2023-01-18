#!/usr/bin/env sh

set -e

OS=`uname -o` # the operating system
prefix=`[ $OS = Android ] && echo $PREFIX/bin || echo ~/.local/bin`

[ -d $prefix ] || mkdir -p $prefix
cp ./flytex.py $prefix/flytex
chmod u+x $prefix/flytex


