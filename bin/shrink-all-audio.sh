#!/bin/bash
[ "$1" = '-h' ] && echo -e"$0 <srcdir> <dstdir>\n\tdefaults: srcdir=.; dstdir=../small" && exit 0

quality="${quality:-8}"
lowpass="${lowpass:-5500}"
highpass="${highpass:-300}"

src="$1"
out="$2"
[ -z "$src" ] && src='.'
[ -z "$out" ] && out='../small'

mkdir -p "${out}"
rm -rf debug.txt success failed

find "$src" -type d | \
while read album; do
	mkdir -p "${out}/${album}"
	find "${album}" -maxdepth 1 -type f | \
	while read track; do 
		if ffmpeg -y -i "${src}/${track}" -codec:a libmp3lame -ac 1 -ar 16000 -q:a ${quality} -map 0 -af "lowpass=f=${lowpass},highpass=f=${highpass}" "${out}/${track}" </dev/null &>>debug.txt; then 
			echo "$track" >> "success"
			echo -e "$track:\n\tsuccess"
		else 
			echo "$track" >> "failed"
			echo -e "$track:\n\tfail"
			rm "${out}/${track}"
		fi
	done
done

