#!/bin/bash
# clean & shring all audio recordings in directory (to somewhere else)
basedir=$(pwd)

bindir=$(readlink -f "$BASH_SOURCE")
bindir=$(dirname "$bindir")
. "${bindir}/common_include.sh"

print_help() 
{
	echo -e "$0 <srcdir> <dstdir>\n\tdefaults: srcdir=.; dstdir=../small"
	echo -e "\t-t audio|video force mt"
	echo -e "see recode-media.sh -h for used exports"
}

while getopts  "hix:t:" arg; do
        case "$arg" in
	h) print_help; exit 0 ;;
        i) export inplace=1 ;;
	x) export extra="$OPTARG" ;;
	t) export media="$OPTARG" ;;
        *) echo "unknown arg $arg" >&2; print_help; exit 1 ;;
	esac
done
shift "$(($OPTIND - 1))"

[ -z "$1" ] && print_help && exit 1

src="$1"
out="$2"
[ -z "$src" ] && src="$basedir"
[ -z "$out" ] && out=$(dirname "$src")/$(basename "$src")-small

src=$(readlink -f "$src")
mkdir -p "${out}"
out=$(readlink -f "$out")

rm -rf "${out}/debug.txt" "${out}/success" "${out}/failed" "${out}/candidates"

get_size()
{
	ls -s "$1" | cut -d ' ' -f 1
}
size_diff()
{
	expr $(get_size "$1") - $(get_size "$2")
}

[ -z "$extra" ] && extra=-y
export extra

[ -n "$inplace" ] && out="$src"

# TODO: go paralell :-)
#
cd "$src"
alist=$(mktemp)
find . -type d >"$alist"
albums=(); while read f;do albums+=( "$f" ); done<"$alist"
for album in "${albums[@]}"; do
	[ -z "$inplace" ] && mkdir -p "${out}/${album}"
	cd "$src/$album"

	find . -maxdepth 1 -type f >"$alist"
	tracks=(); while read f;do tracks+=( "$f" ); done<"$alist"
	for track in "${tracks[@]}"; do
		ftrack="$album/$track"
		mt=$(media_type "${track}")
		[ -n "$media" -a "$mt" = audio -o "$mt" = video ] && \
			mt="$media"
		echo -n "$ftrack($mt):" 

		otrack=""
		case "${mt}" in
			audio)
				[ -z "$inplace" ] && otrack="${album}/${track%.*}.mp3"
				recode-media.sh -S "${track}" "${out}/${otrack}" </dev/zero &>>debug.txt
				res=$?
			;;

			video)
				[ -z "$inplace" ] && otrack="${album}/${track%.*}.mp4"
				downscale_video.sh "${track}" "${out}/${otrack}" </dev/zero &>>debug.txt
				res=$?
			;;
			# no image scaling yet
			*)
				if [ -z "$inplace" ]; then
					otrack="${album}/${track}"
					cp "${track}" "${out}/${otrack}"
					res=$?
				else
					res=0
				fi
			;;
		esac
		if [ "$res" = 0 ]; then
			echo "$ftrack" >> "${out}/success"
			echo -e "\tsuccess"
			[ $(size_diff "${track}" "${out}/${otrack}") -gt $(($(get_size "${track}") / 10)) ] && echo "${ftrack}" >> "${out}/candidates"
		else 
			echo "$ftrack" >> "${out}/failed"
			echo -e "\tfail"
			rm -f "${out}/${otrack}"
		fi
	done
done
rm "$alist"

cd "$basedir"
