#!/bin/bash

if [ -z "$1" ]; then
	echo "$(basename $0) in start end [out]"
	exit 0
fi

in="$1"
st="$2"
end="$3"

out="$4"
[ -z "${out}" ] && out="${in%.*}_1.${in##*.}"

ffmpeg $extra -i "${in}" -codec copy -ss "${st}" -to "${end}" "${out}"

