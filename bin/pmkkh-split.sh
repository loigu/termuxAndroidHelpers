#!/bin/bash

fmt_out() {
	printf '%02d-%s.mp3' "$1" "$2"
}

in="$1"
prefix="$2"
shift 2

b=0
i=0
for e in "$@"; do
	cut-from-mp3.sh "$in" "$b" "$e" "$(fmt_out $i $prefix)"
	b=$e
	i=$(($i + 1))
done
cut-from-mp3.sh "$in" $b -1 "$(fmt_out $i $prefix)"
