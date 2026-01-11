#! /bin/bash
# join video files together
# ts adjustment (24fps)
# -vsync drop -i "concat:join.webm|2.webm" -bsf "setts=ts=N*42"

if [ -z "$1" -o "$#" -lt 3 ]; then
	echo "extra=y $0 [-k] <out> <first> <second> [...]"
	exit 0
fi

[ "$1" = "-k" ] && keep=1 && shift

out="$1"
shift

for i in $(seq 1 $#); do
	in="$(eval echo \$$i)"
	ffmpeg -nostdin ${extra} -i "$in" -c copy -bsf:v h264_mp4toannexb -f mpegts "$in.ts" 
	[ -n "${colist}" ] && colist="$colist|"
	colist="$colist$in.ts"
done

ffmpeg ${extra} -i "concat:$colist" -c copy "$out" # -bsf:a aac_adtstoasc "$out"
[ -z "$keep" ] && rm -f $(echo $colist | tr '|' ' ')
