#!/bin/bash
# cut out segments of media file and "glue" them to single new file

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

function media_type()
{
	file --mime-type -F ''  "$1"  |cut -d " " -f 2 | cut -d '/' -f 1
}

for s in "$@"; do
	st=$(echo $s|cut -d \- -f 1)
	end=$(echo $s|cut -d \- -f 2)

	ffmpeg $extra -i "${in}" -codec copy -ss "${st}" -to "${end}" "$(segname ${out} ${seg})"

	seg=$(expr $seg + 1)
done
seg=$(expr $seg - 1)

segments="$(segname $out 0)"
for seg in $(seq 1 $seg); do
	segments="$segments|$(segname $out $seg)"
done

case $(media_type "$in") in
	audio)
		ffmpeg $extra -i "concat:$segments" -c copy $out
	;;
	video)
		join-video.sh $(test "$do_cleanup" = 1 || echo -k) "${out}" $(echo $segments | tr '|' ' ')
	;;
	*)
		echo unknown media type $(media_type "$1")
	;;
esac
[ "$do_cleanup" = 1 ] && rm $(echo $segments | tr '|' ' ')

