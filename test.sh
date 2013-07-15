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

    for SCRIPT in $(ls $NOOBDIR/$NUM); do
	NOOBPL="$NOOBDIR/$NUM/$SCRIPT"
	# add executable bit for noob script
	chmod +x "$NOOBPL"

	RSOLDIR="$RESULTDIR/$NUM/sol/${SCRIPT%.pl}"

	[ -e "$RSOLDIR" ] || mkdir -p "$RSOLDIR"

	for TEST in $(ls $DATDIR); do
	    DAT="$DATDIR/$TEST"
	    SOL="$SOLDIR/${TEST%dat}sol"
	    ERR="$SOLDIR/${TEST%dat}err"
	    RSOL="$RSOLDIR/${TEST%dat}sol"
	    RERR="$RSOLDIR/${TEST%dat}err"
	    RESULT="$RSOLDIR/result.txt"
	    LINE="${TEST%.dat}"

	    [ -e "$SOL" ] || $MODELPL $DAT >$SOL 2>$ERR
	    [ -e "$RSOL" ] || $NOOBPL $DAT >$RSOL 2>$RERR

	    if diff -q $SOL $RSOL; then
		LINE="ok ${TEST%.dat}"
	    else
		LINE="not ok ${TEST%.dat}"
	    fi

	    echo "$LINE" >> $RESULT
	done
    done
done
