#!/bin/bash

[ -z "$lowpass" ] && lowpass=5512
[ -z "$highpass" ] && highpass=300
[ -z "$quality" ] && quality=9

if [ -z "$1" -o "$1" = "-h" ]; then
	echo -e "\thighpass=$highpass"
	echo -e "\tlowpass=$lowpass"
	echo -e "\tquality=$quality"
	echo "$0 from [to]"
	exit 0
fi

from="$1"
to="$2"
[ -z "${to}" ] && to=$(dirname "$1")/clean-$(basename "$1")

ffmpeg ${extra} -i "${from}" -ac 1 -ar 16000 -q:a ${quality} -map 0 -af "lowpass=f=${lowpass},highpass=f=${highpass}" "${to}"

