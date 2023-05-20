#!/bin/bash
# make mp3 into "static" video in format suitable for youtube upload

if [ -z "$1" ]; then
	echo "$0 <mp3> <image> [out.mov]"
	exit 0
fi

audio="$1"
image="$2"
out="$3"
fps=1
audio_aac="-c:a aac -b:a 24k -ac 1 -ar 11025 -profile:a aac_low"
audio_mp3="-c:a copy"

[ -z "$out" ] && out="${audio%%.[Mm][Pp]3}.mov"

audio_codec="$audio_mp3"
# [ "${out##*.}" = mp4 ] && audio_codec="$audio_aac"

ffmpeg -nostdin $extra -i "$audio" -loop 1 -r 1 -i "$image"  ${audio_codec} -c:v libx264 -r $fps -strict -1 -preset fast -tune stillimage -shortest "$out"

