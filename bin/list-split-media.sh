#!/bin/bash

[ -z "$1" -o "$1" = "-h" ] && echo "$0 mp3 list [printf pattern - containing number name]" && exit 1
src="$1"
flist="$2"
ext="${src##*.}"
pattern="%02d %s" 
[ -n "$3" ] && pattern="$3"

[ -z "$i" ] && i=1
start=''
while read end b nename; do
	if [ -n "$start" ]; then
		fname=$(printf "${pattern}.${ext}" "$i" "${name}")
		cut-from-media.sh "${src}" "$start" "$end" "${fname}"
		i=$(( $i + 1 ))
	fi

	name="${nename}"
	start="${end}"
done < "$flist"

fname=$(printf "${pattern}.${ext}" "$i" "${name}")
cut-from-media.sh "${src}" "$start" "23:59:00" "${fname}"
