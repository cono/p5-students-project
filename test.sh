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

    RESULT="$RESULTDIR/$NUM/sol/result.txt"
    HEADER="n/n"

    for SCRIPT in $(ls $NOOBDIR/$NUM); do
	NOOBPL="$NOOBDIR/$NUM/$SCRIPT"
	# add executable bit for noob script
	chmod +x "$NOOBPL"

	RSOLDIR="$RESULTDIR/$NUM/sol/${SCRIPT%.pl}"
	LINE="${SCRIPT%.pl}"

	[ -e "$RSOLDIR" ] || mkdir -p "$RSOLDIR"

	for TEST in $(ls $DATDIR); do
	    DAT="$DATDIR/$TEST"
	    SOL="$SOLDIR/${TEST%dat}sol"
	    ERR="$SOLDIR/${TEST%dat}err"
	    RSOL="$RSOLDIR/${TEST%dat}sol"
	    RERR="$RSOLDIR/${TEST%dat}err"

	    [ -e "$SOL" ] || $MODELPL $DAT >$SOL 2>$ERR

	    TERMINATE=""
	    if [ ! -e "$RSOL" ]; then
		$NOOBPL $DAT >$RSOL 2>$RERR &
		PID=$!

		for I in 1 2 3 4 5; do
		    sleep 1
		    kill -0 $PID 1>/dev/null 2>&1 || break
		done

		if kill -0 $PID 1>/dev/null 2>&1; then
		    kill -9 $PID 1>/dev/null 2>&1
		    TERMINATE="1"
		fi
	    fi

	    if [ -n "$TERMINATE" ]; then
		LINE="$LINE	T"
	    else
		if diff -q $SOL $RSOL; then
		    LINE="$LINE	+"
		else
		    LINE="$LINE	-"
		fi
	    fi

	    HEADER="$HEADER	${TEST%.dat}"
	done

	if [ -n "$HEADER" ]; then
	    echo "$HEADER" > $RESULT
	    HEADER=""
	fi
	echo "$LINE" >> $RESULT
    done
done
