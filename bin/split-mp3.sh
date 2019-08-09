#!/bin/bash

in="$1"
st="$2"

out1="$3"
out2="$4"
[ -z"${out1}" ] && out1="${in%.*}_1.mp3"
[ -z"${out2}" ] && out2="${in%.*}_2.mp3"

[ "${out1}" != '-' ] && ffmpeg -i "$in" -acodec copy  -to "$st" "${out1}"

[ "${out2}" != '-' ] && ffmpeg -i "$in" -acodec copy  -ss "$st" "${out2}"
