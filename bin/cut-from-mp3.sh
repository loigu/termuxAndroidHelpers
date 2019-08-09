#!/bin/bash

in="$1"
st="$2"
end="$3"

out="$4"
[ -z"${out}" ] && out1="${in%.*}_1.mp3"

ffmpeg -i "$in" -acodec copy -ss "$st" -to "$end" "${out}"

