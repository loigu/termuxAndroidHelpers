#!/bin/bash

if [ -z "$1" -o -z "$2" ]; then
	echo "$(basename $0) [-c] in out from-to from-to ..."
	echo -e "\t -c do cleanup"
	exit 0
fi

do_cleanup=0
if [ "$1" = -c ]; then
	do_cleanup=1
	shift
fi

in="$1"
out="$2"

shift 2
seg=0

#segname filename partno
function segname()
{
	echo $(dirname "$1")/$2-$(basename "$1")
}

for s in "$@"; do
	st=$(echo $s|cut -d \- -f 1)
	end=$(echo $s|cut -d \- -f 2)

	ffmpeg $extra -i "${in}" -acodec copy -ss "${st}" -to "${end}" "$(segname ${out} ${seg})"

	seg=$(expr $seg + 1)
done
seg=$(expr $seg - 1)

segments="$(segname $out 0)"
for seg in $(seq 1 $seg); do
	segments="$segments|$(segname $out $seg)"
done

ffmpeg $extra -i "concat:$segments" -c copy $out

#clean
[ "$do_cleanup" = 1 ] && rm $(echo $segments | tr '|' ' ')
