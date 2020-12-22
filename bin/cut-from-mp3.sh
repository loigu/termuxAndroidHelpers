#!/bin/bash
# cut out part of mp3 to a new file

if [ -z "$1" ]; then
	echo "$(basename $0) in start end [out]"
	exit 0
fi

in="$1"
st="-ss $2"
[ "$3" != "-1" ] && end="-to $3"

out="$4"
[ -z "${out}" ] && out="${in%.*}_1.mp3"

ffmpeg $extra -i "${in}" -acodec copy ${st} ${end} "${out}"

