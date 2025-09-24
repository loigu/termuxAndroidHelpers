#!/bin/bash
# downscale video to lower res & bitrate
bindir=$(readlink -f "$BASH_SOURCE")                              bindir=$(dirname "$bindir")

[ -z "$1" -o "$1" = "-h" ] && echo "[inplace=1]vb=600k;res=854:-1; $0 <in> [out>]" && exit


I="$1"
O="$2"
if [ -n "$inplace" -o "$O" = '-i' ]; then
	d=$(dirname "$I")
	f=$(basename "$I")
	O=$(mktemp -p "$d" "tmp-XXXXXX-${f%%.*}.mp4")
else
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
[ -z "$res" ] && res=-1:-1

passlog=$(mktemp -u ./ffmpeglogXXXX)

vo="-codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v ${vb} -maxrate ${vb} -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -g 30 -bf 2 -passlogfile $passlog"

ffmpeg -nostdin -y -i "$I" ${vo} -pass 1 -f mp4 -an  ${extra} /dev/null || exit $?

# ffmpeg -nostdin -i "$I" ${extra} -codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v $vb -maxrate $vb -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -pass 2 -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 32k -ac 1 -ar 16000 -profile:a aac_low ${extra} "$O"

inplace='' "${bindir}/recode-media.sh" -V "${vo} -pass 2 -movflags +faststart" "$I" "$O"
ret=$?

if [ "$ret" = 0 ]; then
	rm $passlog-[0-9].log

	if [ -n "$inplace" ]; then
		rm "$I"
		mv "$O" "${I%%.*}.mp4"
		ret=$?
	fi
fi

exit $ret

