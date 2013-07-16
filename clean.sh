#! /bin/sh

BINDIR=$(dirname $0)

. $BINDIR/init.sh

find $MODELDIR \( -name '*.sol' -o -name '*.err' \) -exec rm {} \;
find $RESULTDIR \( -name '*.sol' -o -name '*.err' -o -name '*.txt' \) -exec rm {} \;
rm -rf $WORKINGDIR
