#!/bin/bash

[ -z "$2" ] && echo "$0 in.mp3 in.png [out.mp4]" && exit 1

mp3="$1"
img="$2"
[ -z "$3" ] && out="${mp3%%.mp3}.mp4" || out="$3"
ext="${img##*.}"

ffmpeg -i "$mp3" -i "$img" -map 0 -map 1 -c copy \
	-c:v:1 "$ext" -disposition:v:1 attached_pic "$out"
