#!/bin/bash

from="$1"
to="$2"
if [ -z "${to}" ]; then
       	to=$(dirname "$1")/$(basename "$1").mp3
	to="${to%%.*}.mp3"
fi

if [ -z "$from" ]; then
	echo ${basename $0} from [to]
	exit 1
fi

ffmpeg -i "${from}" -ac 1 -map 0 -f mp3 -vn -ar 22050 -ab 64000 "${to}"

