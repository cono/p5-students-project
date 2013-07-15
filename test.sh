#! /bin/sh

BINDIR=$(dirname $0)

for NUM in $(ls $BINDIR/noobs); do
    # Model processing
    MODELPL="$BINDIR/model/$NUM/${NUM}.pl"
    if [ ! -e "$MODELPL" ]; then
	echo "Task $NUM not completed"
	continue
    fi

    # add executable bit for model script
    chmod +x "$MODELPL"

    DATDIR="$BINDIR/model/$NUM/dat"
    SOLDIR="$BINDIR/model/$NUM/sol"
    [ -e "$SOLDIR" ] || mkdir "$SOLDIR"

    for TEST in $(ls $DATDIR); do
	DAT="$DATDIR/$TEST"
	SOL="$SOLDIR/${TEST%dat}sol"
	ERR="$SOLDIR/${TEST%dat}err"

	[ -e "$SOL" ] || $MODELPL $DAT >$SOL 2>$ERR
    done

    for SCRIPT in $(ls $BINDIR/noobs/$NUM); do
	NOOBPL="$BINDIR/noobs/$NUM/$SCRIPT"
	# add executable bit for noob script
	chmod +x "$NOOBPL"

	RESULTDIR="$BINDIR/result"
	SOLDIR="$BINDIR/result/$NUM/sol"

	[ -e "$SOLDIR" ] || mkdir -p "$SOLDIR"
    done
done
