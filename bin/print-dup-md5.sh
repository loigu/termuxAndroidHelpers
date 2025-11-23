#!/bin/bash

[ "$1" = -h ] && echo -e "$0 [in.md5 out]\n if no args then reads stdin, writes stdout" && exit 0

[ -n "$1" ] && in="$1" || in="-"
[ -n "$2" ] && out="$2" || out="1"

sort -k 1 "$in" | while read m f; do 
	if [ "$pm" != "$m" ]; then 
		pm="$m"; pf="$f"
	else 
		[ -n "$pf" ] && echo -e "$m\n\t$pf" && pf=""
		echo -e "\t$f"
	fi
done > "$out"

