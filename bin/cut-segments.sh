#!/bin/bash
# cut out segments of media file and "glue" them to single new file

if [ -z "$1" -o -z "$2" ]; then
	echo "$(basename $0) [-c] in out from-to from-to ..."
	echo -e "\t -c do cleanup"
	exit 0
fi

bindir=$(readlink -f "$0")
bindir=$(dirname "$bindir")

source "${bindir}/common_include.sh"

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

segments=()
for s in "$@"; do
	st=$(echo $s|cut -d \- -f 1)
	end=$(echo $s|cut -d \- -f 2)

	segments[$seg]=$(segname "$out" "$seg")
	cut-from-media.sh "${in}" "${st}" "${end}" "${segments[$seg]}"

	seg=$(expr $seg + 1)
done
seg=$(expr $seg - 1)

case $(media_type "$in") in
	audio)
		join-mp3.sh  "$out" "${segments[@]}"

	;;
	video)
		join-video.sh $(test "$do_cleanup" = 1 || echo -k) "${out}" "${segments[@]}"
	;;
	*)
		echo unknown media type $(media_type "$1")
	;;
esac

[ "$do_cleanup" = 1 ] && rm -f "${segments[@]}"

