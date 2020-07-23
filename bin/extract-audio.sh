#!/bin/bash

[ "$1" = '-h' ] && echo $(basename "$0")" <from> <to>" && exit 0 

from="$1"
to="$2"

if [ -z "$from" ]; then
	echo ${basename $0} from [to]
	exit 1
fi

if [ -z "${to}" ]; then
	d=$(dirname "$1")
	f=$(basename "$1")
	to="$d/${f%%.*}.mp3"
fi

ffmpeg -i "${from}" -ac 1 -map 0 -f mp3 -vn -ar 22050 -ab 64000 "${to}"

