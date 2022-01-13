#!/bin/bash
# compare two directories, list modified & orphaned files 
# TODO: list files found in second dir and not in first too
# consider sqlite3, size compare for update speedup

[ -z "$1" -o "$1" = "-h" ] && echo "[extra='-L' constraints='-not -path whatever']" $(basename "$0") [-f -u -m] "<indir1|infile1.md5> label1 <indir2|infile2.md5> label2 out-prefix" && exit

#todo check relative path comp
#todo: proper readarg

while expr match "$1" '^-[fum]$' &>/dev/null; do
	[ "$1" = '-f' ] && FORCE=1 && shift
	[ "$1" = '-u' ] && UPDATE=1 && shift
	[ "$1" = '-m' ] && MD_ONLY=1 && shift
done

IN1="$1"
LABEL1="$2"
IN2="$3"
LABEL2="$4"
OUT="$5"

[ -n "$OUT" ] && OUT="$OUT-"

expr match "${IN1}" '.*/' &>/dev/null && IN1="${IN1%/}"
expr match "${IN2}" '.*/' &>/dev/null && IN2="${IN2%/}"

make_list()
{
	local old=$(mktemp "$2.old.XXXXXX")
	if [ -f "$2" ]; then
		mv "$2" "$old"
	fi

	find ${extra} "$1" -type f ${constraints} | \
	while read f; do
		local m=''

		[ -f "$old" ] && m=$(grep -m 1 "\ ${f}\$" "$old")
		[ -z "$m" ] && m=$(md5sum "$f")
		echo "$m" >> "$2"
	done

	sort -su -k 2 "$2" > "$old"
	mv "$old" "$2"
}


process_lists()
{
	rm -f "$OUT$LABEL1-only" "$OUT$LABEL1-$LABEL2-dup"

	cat "$IN1" | while read md fl; do 
		grep -q "${md}" "$IN2" && continue
		name=$(basename "${fl}")
		loc=$(grep -m 1 "\ ${name}\$" "$IN2")
		if [ -z "${loc}" ]; then
			echo -e "${md}\t${fl}" >> "$OUT$LABEL1-only"
		else
			echo -e "${LABEL1}\t${fl}\t${LABEL2}\t${loc#*\ }" >> "$OUT$LABEL1-$LABEL2-dup"
		fi
	done 
}

#todo: +dry run / create batch
#add new (add duplicates)
#move (beware of duplicates)
#replace changed (ask first option)
#delete removed (ask first, cleanup empty dirs)

if [ -d "$IN1" ]; then
	[ "$FORCE" = 1 ] && rm -f "$IN1.md5"
	[ -f "$IN1.md5" -a -z "${UPDATE}" ] && IN1="$IN1.md5" && break

	make_list "$IN1" "$IN1.md5" && IN1="$IN1.md5"
fi

if [ -d "$IN2" ]; then
	[ "$FORCE" = 1 ] && rm -f "$IN2.md5"
	[ -f "$IN2.md5" -a -z "${UPDATE}" ] && IN2="$IN2.md5" && break

	make_list "$IN2" "$IN2.md5" && IN2="$IN2.md5"
fi

[ -n "$MD_ONLY" ] && exit 0

process_lists

