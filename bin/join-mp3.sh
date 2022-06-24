#! /bin/bash
# join mp3 files together

if [ -z "$1" -o "$#" -lt 3 ]; then
	echo "extra=y $0 [-r] <out> <first> <second> [...]"
	echo "  -r remove sources after"
	exit 0
fi

keep=1
[ "$1" = "-r" ] && keep=0 && shift

out="$1"
shift

for i in "$@"; do
	[ -n "${colist}" ] && colist="$colist|"
	colist="${colist}${i}"
done

ffmpeg ${extra} -i "concat:$colist" -c copy  "$out"
[ $? = 0 -a "$keep" = 0 ] && rm "$@" || echo "keeping sources (ffmpeg ret $?)"
