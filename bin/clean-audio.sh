#!/bin/bash
# removes noise, cut high & low frequencies, shrinks to "voice" quality

# 200 - 2500 for a.ariya voice
if [ "$quality" = 8 ]; then
	export lowpass=5512
	export highpass=250
	export quality=8
	export rate=16000
fi

if [ "$preset" = pannavudho ]; then
	export highpass=500
        export lowpass=3600
	export volume="2"
	export rate=16000
fi


[ -z "$lowpass" ] && lowpass=2500
[ -z "$highpass" ] && highpass=300
[ -z "$quality" ] && quality=9
[ -z "$rate" ] && rate=11025

[ -n "$normalize" ] && af=',speechnorm=e=50:r=0.0001:l=1'
[ -n "$volume" ] && af="$af,volume=$volume"

#no video by default
[ -z "$video" ] && video=-vn

if [ -z "$1" -o "$1" = "-h" ]; then
	echo -e "\thighpass=$highpass"
	echo -e "\tlowpass=$lowpass"
	echo -e "\tquality=$quality"
	echo -e "\trate=$rate"
	echo -e "\textra=-y"
	echo -e "\tnormalize=y ~ af=,speechnorm=e=50:r=0.0001:l=1"
	echo -e "\tvolume=2 ~ af=,volume=2"
	echo -e "\tpresets... "
	echo -e "\t\tpreset=pannavudho ~ highpass=500,lowpass=3600,volume=30dB"

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

if [ "${to##*.}" != mp3 ]; then
	echo "invalid extension, changing to mp3" >&2
	to="${to%%.*}.mp3" 
fi

ffmpeg -nostdin ${extra} -loglevel warning -stats -i "${from}" -codec:a libmp3lame -ac 1 -ar ${rate} -q:a ${quality}  -map_metadata 0:s:0 -af "lowpass=f=${lowpass},highpass=f=${highpass}${af}" ${video} ${extra2} "${to}" </dev/zero
ret=$?

[ "$?" = 0 -a "${inplace}" = 1 ] && mv "${to}" "${from}"

exit $ret

