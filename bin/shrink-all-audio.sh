#!/bin/bash
[ "$1" = '-h' ] && echo -e"$0 <srcdir> <dstdir>\n\tdefaults: srcdir=.; dstdir=../small" && exit 0
basedir=$(pwd)

quality="${quality:-8}"
lowpass="${lowpass:-5500}"
highpass="${highpass:-300}"
bitrate="${bitrate:-16000}"

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
		if ffmpeg -y -i "${track}" -codec:a libmp3lame -ac 1 -ar ${bitrate} -q:a ${quality} -map 0 -af "lowpass=f=${lowpass},highpass=f=${highpass}" "${out}/${track}" </dev/null &>>debug.txt; then 
			echo "$track" >> "${out}/success"
			echo -e "$track:\n\tsuccess"
			[ $(size_diff "${track}" "${out}/${track}") -gt $(($(get_size "${track}") / 10)) ] && echo "${track}" >> "${out}/candidates"
		else 
			echo "$track" >> "${out}/failed"
			echo -e "$track:\n\tfail"
			rm "${out}/${track}"
		fi
	done
done

cd "$basedir"
