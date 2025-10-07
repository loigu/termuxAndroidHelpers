#!/bin/bash
# split mp3 to multiple files

function print_help()
{
	echo $(basename "$0") '[extra=-y] <infile> <time> [time2 ...]'
	echo $(basename "$0") '[-m outfile_prefix counter_start] <infile> <time1> [time2 time3 ...]'
}

if [ "$1" = '-h' -o -z "$1" ]; then
	print_help
	exit 1
fi

INDEX_LEN=2
function print_fname()
{
	printf "%s_%02d.%s" "${outPrefix}" "$1" "${suffix}"
}

if [ "$1" = '-m' ]; then
	shift
	in="$3"
	outPrefix="$1"
	suffix="${in##*.}"

	i="$2"
	shift 3
else
	in="$1"

	outPrefix="${in%.*}"
	suffix="${in##*.}"
	i=0
	shift 
fi

trackBegin=0
	
for end in $*; do
	ffmpeg -nostdin ${extra} -i "$in" -c:a copy -ss "$trackBegin" -to "$end" "$(print_fname $i)" </dev/zero

	i=$(expr $i + 1)
	trackBegin="$end"
done

out=$(print_fname $i)
ffmpeg -nostdin ${extra} -i "$in" -c:a copy -ss "$trackBegin" "$out" </dev/zero

