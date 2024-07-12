#!/bin/bash

flist="$1"
shift
[ -z "$flist" -o "$flist" = "-h" ] && \
	echo "$0 flist <recode-opts" && exit 1

export def_opts="-S -S"
function recode_single()
{
	recode-media.sh ${def_opts} "$@"
	if [ $? -eq 0 ]; then
		echo "$f: success"
	else
		echo "$f: fail"
	fi
}

i=1
while read f; do  
	[ $i -gt 6 ] && wait -n
	recode_single "$@" "$f" & 
	i=$(( $i + 1))
done < $flist

wait
