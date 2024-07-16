#!/bin/bash
# extract mp3 audio from media file

from="$1"
to="$2"

if [ -z "$from" ] || [ "$1" = '-h' ] ; then
	echo $(basename "$0") from [to]
	echo subscript extras:
	recode-media.sh -h
	exit 1
fi

if [ -z "${to}" ]; then
	d=$(dirname "$1")
	f=$(basename "$1")
	to="$d/${f%%.*}.mp3"
fi

export extra
recode-media.sh "$from" "$to"

