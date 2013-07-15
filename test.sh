#! /bin/sh

BINDIR=$(dirname $0)

. $BINDIR/init.sh

for NUM in $(ls $NOOBDIR); do
    # Model processing
    MODELPL="$MODELDIR/$NUM/${NUM}.pl"
    if [ ! -e "$MODELPL" ]; then
	echo "Task $NUM not completed"
	continue
    fi

    # add executable bit for model script
    chmod +x "$MODELPL"

    DATDIR="$MODELDIR/$NUM/dat"
    SOLDIR="$MODELDIR/$NUM/sol"
    [ -e "$SOLDIR" ] || mkdir "$SOLDIR"

    for TEST in $(ls $DATDIR); do
	DAT="$DATDIR/$TEST"
	SOL="$SOLDIR/${TEST%dat}sol"
	ERR="$SOLDIR/${TEST%dat}err"

	[ -e "$SOL" ] || $MODELPL $DAT >$SOL 2>$ERR
    done

    for SCRIPT in $(ls $NOOBDIR/$NUM); do
	NOOBPL="$NOOBDIR/$NUM/$SCRIPT"
	# add executable bit for noob script
	chmod +x "$NOOBPL"

	SOLDIR="$RESULTDIR/$NUM/sol"

	[ -e "$SOLDIR" ] || mkdir -p "$SOLDIR"
    done
done
