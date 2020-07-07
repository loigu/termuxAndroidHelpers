#!/bin/bash

[ -z "$lowpass" ] && lowpass=5512
[ -z "$highpass" ] && highpass=300
[ -z "$quality" ] && quality=9

if [ -z "$1" -o "$1" = "-h" ]; then
	echo -e "\thighpass=$highpass"
	echo -e "\tlowpass=$lowpass"
	echo -e "\tquality=$quality"
	echo "$0 from [to]"
	echo "to == -i -> inplace"
	exit 0
fi

from="$1"
to="$2"
[ "$to" = "-i" ] && inplace=1 && to=""
[ -z "${to}" ] && to=$(dirname "$1")/clean-$(basename "${1%.*}").mp3

[ -d "$to" ] && to="$to/$(basename $from)"

ffmpeg ${extra} -i "${from}" -codec:a libmp3lame -ac 1 -ar 16000 -q:a ${quality} -map 0 -af "lowpass=f=${lowpass},highpass=f=${highpass}" "${to}"
ret=$?

[ "$?" = 0 -a "${inplace}" = 1 ] && mv "${to}" "${from}"

exit $ret

