#!/bin/bash

s=$(readlink -f "$BASH_SOURCE")
d=$(dirname "$s")

. "$d/common_include.sh"

flist="$1"
shift
[ -z "$flist" -o "$flist" = "-h" ] && \
	echo "[paralell=6] $0 flist <recode-opts>" && exit 1

[ -z "$loglevel" ] && export loglevel=16

function recode_single()
{
	local track="$1"
	shift

	local log=/dev/null
	[ "$loglevel" -gt 16 ] && log="$track-debug.txt"

	local mt=$(media_type "${track}")
	[ -n "$media" ] && [ "$mt" = audio -o "$mt" = video ] && \
                        mt="$media"

	echo -e "START:\t$track ($mt)"
	case "${mt}" in
		audio)
                        recode-media.sh "$@" "${track}" </dev/zero &>>"$log"
                        res=$?
                        ;;
		video)
			downscale-video.sh "${track}"  </dev/zero &>>"$log"
                        res=$?
                        ;;
		image)
			resize-img.sh "$track" "$@"
			res=$?
			;;
                *)
				echo "unknown media type for $track" >&2
				res=1;
                        ;;
                esac

	if [ $res -eq 0 ]; then
		echo -e "_SUCC:\t$f"
		[ "$loglevel" -gt 16 ] && echo "$f" >>success
	else
		echo -e "_FAIL:\t$f"
		echo "$f" >>failed
	fi
	return $res
}

if [ -d "$flist" ]; then
	t=$(mktemp)
	find "$flist" -iname "*.mp3" -o -iname "*.m4a" >"$t"
	flist="$t"
fi

[ -z "$paralell" ] && export paralell=6
i=1
while read f; do  
	[ "$i" -gt "$paralell" ] && wait -n
	recode_single "$f" "$@" & 
	i=$(( $i + 1 ))
done < "$flist"

wait
[ -f "$t" ] && rm "$t"

