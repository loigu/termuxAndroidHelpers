#!/bin/bash
# make mp3 into "static" video in format suitable for youtube upload

if [ -z "$1" ]; then
	echo "$0 <mp3> <image> [out.mov]"
	exit 0
fi

audio="$1"
image="$2"
out="$3"

[ -z "$out" ] && out="${audio%%.[Mm][Pp]3}.mov"

ffmpeg -nostdin -i "$audio" -loop 1 -r 1 -i "$image"  -c:a copy -c:v libx264 -preset fast -tune stillimage -shortest "$out"

