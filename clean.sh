#! /bin/sh

BINDIR=$(dirname $0)

. $BINDIR/init.sh

find $MODELDIR \( -name '*.sol' -o -name '*.err' \) -exec rm {} \;
