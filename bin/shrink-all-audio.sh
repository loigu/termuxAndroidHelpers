#!/bin/bash
# clean & shring all audio recordings in directory (to somewhere else)

[ -z "$1" -o "$1" = '-h' ] && echo -e"$0 <srcdir> <dstdir>\n\tdefaults: srcdir=.; dstdir=../small" && exit 0
basedir=$(pwd)

src="$1"
out="$2"
[ -z "$src" ] && src='.'
[ -z "$out" ] && out='../small'

mkdir -p "${out}"
out=$(cd "$out" && pwd)

rm -rf "${out}/debug.txt" "${out}/success" "${out}/failed" "${out}/candidates"

get_size()
{
	ls -s "$1" | cut -d ' ' -f 1
}
size_diff()
{
	expr $(get_size "$1") - $(get_size "$2")
}

cd "$src"
find ./ -type d | \
while read album; do
	mkdir -p "${out}/${album}"
	find "${album}" -maxdepth 1 -type f | \
	while read track; do
		extra=-y
		otrack="${track%.*}.mp3"
		if clean-audio.sh "${track}" "${out}/${otrack}" </dev/null &>>debug.txt; then 
			echo "$track" >> "${out}/success"
			echo -e "$track:\n\tsuccess"
			[ $(size_diff "${track}" "${out}/${otrack}") -gt $(($(get_size "${track}") / 10)) ] && echo "${track}" >> "${out}/candidates"
		else 
			echo "$track" >> "${out}/failed"
			echo -e "$track:\n\tfail"
			rm "${out}/${otrack}"
		fi
	done
done

cd "$basedir"
