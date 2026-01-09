#!/bin/bash
# downscale video to lower res & bitrate
bindir=$(readlink -f "$BASH_SOURCE")
export bindir=$(dirname "$bindir")

[ -z "$vb" ] && vb=600k
[ -z "$res" ] && res=-1:-1

if [ "$1" = -passlog ]; then
	passlog="$2"
	skip_p1=y
	shift 2
fi

[ -z "$1" -o "$1" = "-h" ] && echo -e "[inplace=1]vb=${vb};res=${res}; $0 <in> [out]\n\t+ audio exports for recode-media.sh" && exit


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

[ -z "$passlog" ] && passlog=$(mktemp -u ./ffmpeglogXXXX)

vo="-codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v ${vb} -maxrate ${vb} -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -g 30 -bf 2 -passlogfile $passlog"

if [ -z "${skip_p1}" ]; then
	ffmpeg -nostdin -y -i "$I" ${vo} -pass 1 -f mp4 -an  ${extra} /dev/null || exit $?
fi

# ffmpeg -nostdin -i "$I" ${extra} -codec:v libx264 -tune zerolatency -preset slow -profile:v high -b:v $vb -maxrate $vb -bufsize 15000k -pix_fmt yuv420p -vf fps=fps=20,scale=$res -pass 2 -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 32k -ac 1 -ar 16000 -profile:a aac_low ${extra} "$O"

inplace='' "${bindir}/recode-media.sh" -V "${vo} -pass 2 -movflags +faststart" "$I" "$O"
ret=$?

if [ "$ret" = 0 ]; then
	[ -z "$debug" ] && rm $passlog-[0-9].log

	if [ -n "$inplace" ]; then
		rm "$I"
		mv "$O" "${I%%.*}.mp4"
		ret=$?
	fi
fi

exit $ret

