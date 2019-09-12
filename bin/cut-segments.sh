#!/bin/bash

if [ -z "$1" -o -z "$2" ]; then
	echo "$(basename $0) in out from-to from-to ..."
	exit 0
fi

in="$1"
out="$2"

shift 2
seg=0
for s in "$@"; do
	st=$(echo $s|cut -d \- -f 1)
	end=$(echo $s|cut -d \- -f 2)

	ffmpeg $extra -i "${in}" -acodec copy -ss "${st}" -to "${end}" "$seg-${out}"

	seg=$(expr $seg + 1)
done
seg=$(expr $seg - 1)

segments="0-$out"
for seg in $(seq 1 $seg); do
	segments="$segments|$seg-$out"
done

ffmpeg $extra -i "concat:$segments" -c copy $out

#todo: clean
