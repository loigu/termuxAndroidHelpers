#! /bin/bash

i="$1"
j="$2"
out="$3"
[ -z "$out" ] && out="$(dirname $1)/joined-$(basename $1)"

ffmpeg -i "$i" -c copy -bsf:v h264_mp4toannexb -f mpegts "$i.ts" 
ffmpeg -i "$j" -c copy -bsf:v h264_mp4toannexb -f mpegts "$j.ts"

ffmpeg -i "concat:$i.ts|$j.ts" -c copy -bsf:a aac_adtstoasc "$out" 
