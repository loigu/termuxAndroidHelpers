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
	echo -e "see clean-audio.sh -h for other options"
}

while getopts  "hiH:l:q:b:v:p:x:t:" arg; do
        case "$arg" in
		h) print_help; exit 0 ;;
        i) export inplace=1 ;;
	H) export highpass="$OPTARG" ;;
        l) export lowpass="$OPTARG" ;;
	q) export quality="$OPTARG" ;;
	v) export volume="$OPTRG" ;;
	b) export rate="$OPTARG" ;;   
	p) export preset="$OPTARG" ;;
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

cd "$src"
alist=$(mktemp)
find . -type d >"$alist"
albums=(); while read f;do albums+=( "$f" ); done<"$alist"
for album in "${albums[@]}"; do
	mkdir -p "${out}/${album}"
	cd "$src/$album"

	find . -maxdepth 1 -type f >"$alist"
	tracks=(); while read f;do tracks+=( "$f" ); done<"$alist"
	for track in "${tracks[@]}"; do
		ftrack="$album/$track"
		mt=$(media_type "${track}")
		[ -n "$media" -a "$mt" = audio -o "$mt" = video ] && \
			mt="$media"
		echo -n "$ftrack($mt):" 

		case "${mt}" in
			audio)
				otrack="${album}/${track%.*}.mp3"
				clean-audio.sh "${track}" "${out}/${otrack}" </dev/zero &>>debug.txt
				res=$?
			;;

			video)
				otrack="${album}/${track%.*}.mp4"
				downscale_video.sh "${track}" "${out}/${otrack}" </dev/zero &>>debug.txt
				res=$?
			;;
			# no image scaling yet
			*)
				otrack="${album}/${track}"
				cp "${track}" "${out}/${otrack}"
				res=$?
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
