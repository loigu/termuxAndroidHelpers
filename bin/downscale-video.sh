#!/bin/bash
# downscale video to lower res & bitrate
bindir=$(readlink -f "$BASH_SOURCE")                              bindir=$(dirname "$bindir")

[ -z "$1" -o "$1" = "-h" ] && echo "[inplace=1]vb=600k;res=854:-1; $0 <in> [out>]" && exit


I="$1"
O="$2"
if [ -z "$inplace" ]; then
	if [ -z "$O" ]; then
		d=$(dirname "$I")
		f=$(basename "$I")
		O="$d/small-${f%%.*}.mp4"
	fi

	if [ "${O##*.}" != mp4 ]; then
	       echo "invalid extension, changing to mp4" >&2
	       O="${O%%.*}.mp4"
	fi
fi


[ -z "$vb" ] && vb=600k
[ -z "$res" ] && res=854:-1

vo="-codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v ${vb} -maxrate ${v}b -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -g 30 -bf 2" 

ffmpeg -nostdin -y -i "$I" ${vo} -pass 1 -an -f mp4 ${extra} /dev/null || exit $?

# ffmpeg -nostdin -i "$I" ${extra} -codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v $vb -maxrate $vb -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -pass 2 -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 32k -ac 1 -ar 16000 -profile:a aac_low ${extra} "$O"

"${bindir}/recode-media.sh" -v "${vo} -pass 2 -movflags +faststart" "$I" "$O"
