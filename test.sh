#! /bin/sh

BINDIR=$(dirname $0)

. $BINDIR/init.sh

TESTFILE="$WORKINGDIR/test.txt"

function generate_text_file() {
    [ -f "$TESTFILE" ] && return;
    touch $TESTFILE

    arry=(cccc aaaa aabb bbbb);
    for i in "${arry[@]}"; do
	echo $i>>$TESTFILE
    done
}

for NUM in $(ls $NOOBDIR); do
    echo "Processing task $NUM"

    # Model processing
    MODELPL_SCRIPT_NAME="${NUM}.pl"
    MODELPL="$MODELDIR/$NUM/$MODELPL_SCRIPT_NAME"
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
	    DAT_FILE="$TEST"
	    SOL_FILE="${TEST%dat}sol"
	    ERR_FILE="${TEST%dat}err"

            DAT_PATH="$DATDIR/$DAT_FILE"
            SOL_PATH="$SOLDIR/$SOL_FILE"
            ERR_PATH="$SOLDIR/$ERR_FILE"
	    RSOL_PATH="$RSOLDIR/$SOL_FILE"
            RERR_PATH="$RSOLDIR/$ERR_FILE"

            # execute in working dir
            if [ ! -e "$SOL" ]; then
                cp $MODELPL $WORKINGDIR
		cp $DAT_PATH $WORKINGDIR
                generate_text_file

                cd $WORKINGDIR

                "./$MODELPL_SCRIPT_NAME" "./$DAT_FILE" >"./$SOL_FILE" 2>"./$ERR_FILE"

                cd - >/dev/null 2>&1
		rm -rf "$WORKINGDIR/$MODELPL_SCRIPT_NAME" $TESTFILE "$WORKINGDIR/$DAT_FILE"
		mv $WORKINGDIR/$SOL_FILE $SOL_PATH
		mv $WORKINGDIR/$ERR_FILE $ERR_PATH
            fi

	    TERMINATE=""

            if [ ! -e "$RSOL" ]; then
                cp $NOOBPL $WORKINGDIR
		cp $DAT_PATH $WORKINGDIR
                generate_text_file
                cd $WORKINGDIR

                "./$SCRIPT" "$DAT_FILE" >"./$SOL_FILE" 2>"$ERR_FILE" &
		PID=$!

		sleep 0.3 > /dev/null 2>&1
		for I in 1 2 3 4 5; do
		    kill -0 $PID >/dev/null 2>&1 || break
		    sleep 1
		done

		if kill -0 $PID >/dev/null 2>&1; then
		    kill -9 $PID >/dev/null 2>&1
		    TERMINATE="1"
		fi

                cd - >/dev/null 2>&1
		rm -rf "$WORKINGDIR/$SCRIPT" $TESTFILE "$WORKINGDIR/$DAT_FILE"
		mv $WORKINGDIR/$SOL_FILE $RSOL_PATH
		mv $WORKINGDIR/$ERR_FILE $RERR_PATH
            fi

	    if [ -n "$TERMINATE" ]; then
		echo "[T] ${SCRIPT%.pl} ${TEST%.dat}"
		LINE="$LINE	T"
	    else
		if diff -q $SOL_PATH $RSOL_PATH >/dev/null 2>&1; then
		    echo "[+] ${SCRIPT%.pl} ${TEST%.dat}"
		    LINE="$LINE	+"
		else
		    echo "[-] ${SCRIPT%.pl} ${TEST%.dat}"
		    LINE="$LINE	-"
		fi
	    fi

	    if [ -n "$HEADER" ]; then
		HEADER="$HEADER	${TEST%.dat}"
	    fi
        done

	if [ -n "$HEADER" ]; then
	    echo "$HEADER" > $RESULT
	    HEADER=""
	fi
	echo "$LINE" >> $RESULT
    done
done
