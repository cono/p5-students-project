#! /bin/sh

BINDIR=$(dirname $0)

NOOBDIR="$BINDIR/noobs"
MODELDIR="$BINDIR/model"
RESULTDIR="$BINDIR/result"

[ -e "$NOOBDIR" ] || mkdir $NOOBDIR
[ -e "$RESULTDIR" ] || mkdir $RESULTDIR
