#!/bin/bash
# compare two directories, list modified & orphaned files 
# TODO: list files found in second dir and not in first too

[ -z "$1" -o "$1" = "-h" ] && echo "[extra='-L' constraints='-not -path whatever']" $(basename "$0") [-f] "<indir1|infile1.md5> label1 <indir2|infile2.md5> label2 out-prefix" && exit

[ "$1" = '-f' ] && FORCE=1 && shift

IN1="$1"
LABEL1="$2"
IN2="$3"
LABEL2="$4"
OUT="$5"

[ -n "$OUT" ] && OUT="$OUT-"

expr match "${IN1}" '.*/' && IN1="${IN1%/}"
expr match "${IN2}" '.*/' && IN2="${IN2%/}"

make_list()
{
	find ${extra} "$1" -type f ${constraints} | while read f; do md5sum "$f" >> "$2"; done
}


process_lists()
{
	rm -f "$OUT$LABEL1-only" "$OUT$LABEL1-$LABEL2-dup"

	cat "$IN1" | while read md fi; do 
		grep -q "${md}" "$IN2" && continue
		name=$(basename "${fi}")
		loc=$(grep -m 1 "\ ${name}\$" "$IN2")
		if [ -z "${loc}" ]; then
			echo -e "${md}\t${fi}" >> "$OUT$LABEL1-only"
		else
			echo -e "${LABEL1}\t${fi}\t${LABEL2}\t${loc#*\ }" >> "$OUT$LABEL1-$LABEL2-dup"
		fi
	done 
}

if [ -d "$IN1" ]; then
	[ -f "$IN1.md5" -a -z "${FORCE}" ] && IN1="$IN1.md5" && break

	rm -f "$IN1.md5"
	make_list "$IN1" "$IN1.md5" && IN1="$IN1.md5"
fi

if [ -d "$IN2" ]; then
	[ -f "$IN2.md5" -a -z "${FORCE}" ] && IN2="$IN2.md5" && break

	rm -f "$IN2.md5"
	make_list "$IN2" "$IN2.md5" && IN2="$IN2.md5"
fi

process_lists

