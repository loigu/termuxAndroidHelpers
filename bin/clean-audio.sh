#!/bin/bash
# removes noise, cut high & low frequencies, shrinks to "voice" quality

# 200 - 2500 for a.ariya voice
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
bn=$(basename "${1%.*}").mp3
dn=$(dirname "$1")

to="$2"
[ "$to" = "-i" ] && inplace=1 && to=""

[ -z "${to}" ] && to="$dn/clean-$bn"

[ -d "$to" ] && to="$to/$bn"

ffmpeg ${extra} -i "${from}" -codec:a libmp3lame -ac 1 -ar 16000 -q:a ${quality} -map 0 -map_metadata 0:s:0 -af "lowpass=f=${lowpass},highpass=f=${highpass}" "${to}"
ret=$?

[ "$?" = 0 -a "${inplace}" = 1 ] && mv "${to}" "${from}"

exit $ret

