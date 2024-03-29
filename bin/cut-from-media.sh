#!/bin/bash
# cut to a new file a part of media file (audio/video)

if [ ! -f "$1" -o "$1" = '-h' ]; then
	echo "$(basename $0) in start end [out]"
	exit 0
fi

in="$1"
st="$2"
end="$3"

out="$4"
[ -z "${out}" ] && out="${in%.*}_1.${in##*.}"

ffmpeg -nostdin $extra -i "${in}" -codec copy -ss "${st}" -to "${end}" "${out}"

