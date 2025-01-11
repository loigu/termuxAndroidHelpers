#!/bin/bash

flist="$1"
shift
[ -z "$flist" -o "$flist" = "-h" ] && \
	echo "[paralell=6] $0 flist <recode-opts>" && exit 1

export def_opts="-S -S"
function recode_single()
{
	echo -e "START:\t$f"
	recode-media.sh ${def_opts} "$@"
	if [ $? -eq 0 ]; then
		echo -e "_SUCC:\t$f"
		return 0
	else
		echo -e "FAIL:\t$f"
		return 1
	fi
}

if [ -d "$flist" ]; then
	t=$(mktemp)
	find "$flist" -iname "*.mp3" -o -iname "*.m4a" >"$t"
	flist="$t"
fi

[ -z "$paralell" ] && export paralell=6
i=1
while read f; do  
	[ "$i" -gt "$paralell" ] && wait -n
	recode_single "$@" "$f" & 
	i=$(( $i + 1 ))
done < "$flist"

wait
[ -f "$t" ] && rm "$t"

