#!/bin/bash

fmt_out() {
	printf '%02d-%s.mp3' "$1" "$2"
}

print_help() {
	echo "$(basename \"$0\") [-p prefix] [-i count start] [-h] <in> split1 split2 ..."
}

i=0
while true; do
	case "$1" in
		-h) print_help; exit 0;;
		-p) prefix="$2"; shift;;
		-i) i="$2"; shift;;
		*) break;;
	esac
	shift
done </dev/null
in="$1"
shift

[ -n "$prefix" ] || prefix="${in%.*}"

[ ! -f "$in" ] && print_help && exit 1

b=0
for e in "$@"; do
	cut-from-mp3.sh "$in" "$b" "$e" "$(fmt_out $i $prefix)"
	b=$e
	i=$(($i + 1))
done
cut-from-mp3.sh "$in" $b -1 "$(fmt_out $i $prefix)"
