#!/bin/bash
# removes noise, cut high & low frequencies, shrinks to "voice" quality

function print_help()
{
	echo -e "\t[-h] help"
	echo -e "\t[-H] highpass=$highpass"
	echo -e "\t[-l] lowpass=$lowpass"
	echo -e "\t[-q] quality=$quality"
	echo -e "\t[-b] rate=$rate"
	echo -e "\t[-i] inplace"
	echo -e "\t[-x] extra="
	echo -e "\t[-n] no filters (speeds up...)"
	echo -e "\tnormalize=y ~ af=,speechnorm=e=50:r=0.0001:l=1"
	echo -e "\t[-v] volume=2 ~ af=,volume=2"
	echo -e "\tpresets... "
	echo -e "\t[-p]\tpreset= [ad|pannavudh]"

	echo "$0 from [to]"
}

while getopts  "hiH:l:q:b:v:p:x:n" arg; do
        case $arg in
        h) print_help; exit 0 ;;
	n) export no_filtering=y
	i) export inplace=1 ;; 
	H) export highpass="$OPTARG" ;;
	l) export lowpass="$OPTARG" ;;
	q) export quality="$OPTARG" ;;
	v) export volume="$OPTRG" ;;
	b) export rate="$OPTARG" ;;
	p) preset="$OPTARG" ;;
	x) export extra="$OPTARG" ;;
	*) echo "unknown arg $arg" >&2; print_help; exit 1 ;;
        esac
done
shift $(($OPTIND - 1))

[ -z "$1" ] && print_help && exit 1

from="$1"
bn=$(basename "${1%.*}").mp3
dn=$(dirname "$1")

to="$2"
[ -n "$inplace" ] && to=""

[ -z "${to}" ] && to="$dn/clean-$bn"
[ -d "$to" ] && to="$to/$bn"

if [ "${to##*.}" != mp3 ]; then
	echo "invalid extension, changing to mp3" >&2
	to="${to%%.*}.mp3" 
fi

# 200 - 2500 for a.ariya voice
if [ "$preset" = ad ]; then
	export lowpass=5512
	export highpass=250
	export quality=6
	export rate=22050
fi

if [ "$preset" = pannavudho ]; then
	export highpass=500
        export lowpass=3600
	export volume="2"
	export rate=16000
fi


[ -z "$lowpass" ] && lowpass=2500
[ -z "$highpass" ] && highpass=300
[ -z "$quality" ] && quality=8
[ -z "$rate" ] && rate=16000

[ -n "$normalize" ] && af=',speechnorm=e=50:r=0.0001:l=1'
[ -n "$volume" ] && af="$af,volume=$volume"

#no video by default
[ -z "$video" ] && video=-vn

[ -z  "$no_filtering" ] && af="lowpass=f=${lowpass},highpass=f=${highpass}${af}" || af=""
ffmpeg -nostdin ${extra} -loglevel warning -stats -i "${from}" -codec:a libmp3lame -ac 1 -ar ${rate} -q:a ${quality}  -map_metadata 0:s:0 -af "${af}" ${video} ${extra2} "${to}" </dev/zero
ret=$?

[ "$?" = 0 -a "${inplace}" = 1 ] && mv "${to}" "${from}"

exit $ret

