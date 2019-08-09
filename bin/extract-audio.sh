#!/bin/bash

from="$1"
to="$2"
[ -z "${to}" ] && to=$(dirname "$1")/$(basename "$1").mp3

ffmpeg -i "${from}" -ac 1 -map 0 -f mp3 -vn -ar 22050 -ab 64000 "${to}"

