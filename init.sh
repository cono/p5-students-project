#! /bin/sh

BINDIR=$(dirname $0)

NOOBDIR="$BINDIR/noobs"
MODELDIR="$BINDIR/model"
RESULTDIR="$BINDIR/result"
WORKINGDIR="$BINDIR/work"

[ -e "$NOOBDIR" ] || mkdir $NOOBDIR
[ -e "$RESULTDIR" ] || mkdir $RESULTDIR
[ -e "$WORKINGDIR" ] || mkdir $WORKINGDIR
