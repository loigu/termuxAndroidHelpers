#!/bin/bash

rm debug.txt failed

quality=8
lowpass=5500
highpass=300

src="$1"
out="$2"
list="$3"

[ -z "$src" ] && src='.'
[ -z "$out" ] && out='../small'
[ -z "$list" ] && list=tbd

if [ ! -f "${list}" ]; then
	find "${src}" -type f > "${list}"
fi

mkdir -p "${out}"

line=1
skipped=0
failed=0
success=0
broken=0


max=$(wc -l "${list}")
while true; do
	track="$(head -n $line "${list}" |tail -n 1)"
	line="$(expr $line + 1)"
	if [ ${line} -gt $max ]; then
		echo -e "\ndone: lines $lines, success $success, failed $failed, skipped $skipped, broken $broken"
		break
	fi

	echo "${track}:"
	if [ ! -f "${track}" ]; then
		broken=$(expr $broken + 1)
		echo -e "\tbroken"
		continue
	fi

	if grep -q "^${track}$" success; then
		echo -e "\talready done"
		skipped=$(expr $skipped + 1)
		continue
	fi

	if ffmpeg -y -i "${track}" -codec:a libmp3lame -ac 1 -ar 16000 -q:a ${quality} -map 0 -af "lowpass=f=${lowpass},highpass=f=${highpass}" "${out}/${track%.*}.mp3" &>>debug.txt; then 
			echo "${track}" >> "success"
			echo -e "\tsuccess"
			success=$(expr $success + 1)
		else 
			echo "$track" >> "failed"
			echo -e "\tfail"
			failed=$(expr $failed + 1)
		fi
done

