#!/bin/bash
# downscale video to lower res & bitrate

[ -z "$1" -o "$1" = "-h" ] && echo "bitrate=600k;res=854:-1; $0 <in> [out>]" && exit

I="$1"
O="$2"
if [ -z "$O" ]; then
	d=$(dirname "$I")
	f=$(basename "$I")
	O="$d/small-${f%%.*}.mp4"
fi

if [ "${O##*.}" != mp4 ]; then
       echo "invalid extension, changing to mp4" >&2
       O="${O%%.*}.mp4"
fi


[ -z "$bitrate" ] && bitrate=600k
[ -z "$res" ] && res=854:-1

ffmpeg -nostdin -y -i "$I" ${extra} -codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v $bitrate -maxrate $bitrate -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -pass 1 -g 30 -bf 2 -an -f mp4 ${extra} /dev/null

ffmpeg -nostdin -i "$I" ${extra} -codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v $bitrate -maxrate $bitrate -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -pass 2 -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 32k -ac 1 -ar 16000 -profile:a aac_low ${extra} "$O"


