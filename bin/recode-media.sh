#!/bin/bash
# removes noise, cut high & low frequencies, shrinks to "voice" quality

[ -z "$lowpass" ] && lowpass=2500
[ -z "$highpass" ] && highpass=300
[ -z "$quality" ] && quality=8
[ -z "$rate" ] && rate=16000

[ -n "$normalize" ] && af=',speechnorm=e=50:r=0.0001:l=1'
[ -n "$volume" ] && af="$af,volume=$volume"

#no video by default
[ -z "$codec" ] && export codec=mp3
[ -z "$video" ] && export video=-vn
[ -z "$loglevel" ] && export loglevel=32


function print_help()
{
	echo -e "\t[-h] help"
	echo -e "\t[-H] highpass=$highpass"
	echo -e "\t[-l] lowpass=$lowpass"
	echo -e "\t[-q] quality=$quality"
	echo -e "\t[-b] rate=$rate"
	echo -e "\t[-i] inplace"
	echo -e "\t[-x] extra="
	echo -e "\t[-n] no_filtering=y (speeds up...)"
	echo -e "\t[-S] quiet(er) - pass more times to silence more"
	echo -e "\t[-N] normalize=y ~ af=,speechnorm=e=50:r=0.0001:l=1"
	echo -e "\t[-v] volume=2 ~ af=,volume=2"
	echo -e "\t[-c] codec (mp3 aac)"
	echo -e "\t[-V] video=$video"
	echo -e "\tpresets... "
	echo -e "\t[-p]\tpreset= [ad|pannavudh]"

	echo "$0 from [to]"
}

while getopts  "hNiSH:c:l:q:b:v:p:x:nV:" arg; do
        case $arg in
        h) print_help; exit 0 ;;
	n) export no_filtering=y ;;
	i) export inplace=1 ;; 
	S) loglevel=$(( $loglevel - 8 )) ;;
	H) export highpass="$OPTARG" ;;
	l) export lowpass="$OPTARG" ;;
	q) export quality="$OPTARG" ;;
	v) export volume="$OPTRG" ;;
	c) export codec="$OPTARG" ;;
	V) export video="$OPTARG" ;;
	N) export normalize="$OPTARG" ;;
	b) export rate="$OPTARG" ;;
	p) preset="$OPTARG" ;;
	x) export extra="$OPTARG" ;;
	*) echo "unknown arg $arg" >&2; print_help; exit 1 ;;
        esac
done
shift $(($OPTIND - 1))

[ "$loglevel" -lt 32 ] && extra="$extra -nostats"
[ -z "$1" ] && print_help && exit 1

from="$1"
bn=$(basename "${1}")
dn=$(dirname "$1")
[ "$video" = "-vn" ] && bn="${bn%.*}.mp3"

to="$2"
[ -n "$inplace" ] && to=""

[ -z "${to}" ] && to="$dn/clean-$bn"
[ -d "$to" ] && to="$to/$bn"

if [ "$video" = "-vn" ]; then
	[ "$codec" = aac ] && ext=m4a || ext=mp3
	to="${to%.*}.${ext}" 
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

[ -z  "$no_filtering" ] && af="-af lowpass=f=${lowpass},highpass=f=${highpass}${af}" || af=""

audio="-c:a libmp3lame -q:a ${quality}"
 [ "$codec" = aac ] && audio="-c:a aac -b:a $(( 192 / ${quality} ))k -profile:a aac_low"

ffmpeg -nostdin ${extra} -loglevel $loglevel -i "${from}" ${audio} -ac 1 -ar ${rate} -map_metadata 0:s:0 ${af} ${video} ${extra2} "${to}" </dev/zero
ret=$?

if [ "$?" = 0 -a "${inplace}" = 1 ]; then
	mv "${to}" "${from}"
	fe="${from%.*}.${ext}"
	[ "$fe" != "$from" ] && mv "$from" "$fe"
fi

exit $ret

