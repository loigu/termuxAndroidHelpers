#!/bin/bash

if [ -z "$1" ]; then
	echo "$0 <mp3> <image> [out.mov]"
	exit 0
fi

audio="$1"
image="$2"
out="$3"

[ -z "$out" ] && out="${audio%%.mp3}.mov"

ffmpeg -i "$audio" -loop 1 -r 1 -i "$image"  -c:a copy -c:v libx264 -preset fast -tune stillimage -shortest "$out"

