#!/bin/bash

fmt_out() {
	printf '%s_%02d.mp3' "$1" "$2"
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
	name=$(fmt_out $prefix $i)
	cut-from-media.sh "$in" "$b" "$e" "${name}"
	id3v2 -A 'per rule patimokkha' -a 'Ajahn Khemmanando' -T $i -t "${name%%.mp3}" "${name}"
	b=$e
	i=$(($i + 1))
done

name=$(fmt_out $prefix $i)
cut-from-media.sh "$in" $b -1 "${name}"
id3v2 -A 'per rule patimokkha' -a 'Ajahn Khemmanando' -T $i -t "${name%%.mp3}" "${name}"
