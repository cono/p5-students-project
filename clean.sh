#! /bin/sh

BINDIR=$(dirname $0)

find $BINDIR/model \( -name '*.sol' -o -name '*.err' \) -exec rm {} \;
