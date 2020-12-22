#!/bin/bash
# downscale video to lower res & bitrate

[ -z "$1" -o "$1" = "-h" ] && echo "bitrate=600k;res=854:-1; $0 <in> [out>]" && exit

I="$1"
O="$2"
[ -z "$O" ] && O="small-$I"

[ -z "$bitrate" ] && bitrate=600k
[ -z "$res" ] && res=854:-1

ffmpeg -i "$I" -codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v $bitrate -maxrate $bitrate -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -pass 1 -g 30 -bf 2 -an -f mp4 ${extra} /dev/null

ffmpeg -i "$I" -codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v $bitrate -maxrate $bitrate -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -pass 2 -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 32k -ac 1 -ar 16000 -profile:a aac_low ${extra} "$O"


