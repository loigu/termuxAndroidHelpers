#!/bin/bash

function print_help()
{
	echo $(basename "$0") '<infile> <time>'
	echo $(basename "$0") '-m <infile> <outfile_prefix> <counter_start> <time1> [time2 time3 ...]'
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
	in="$1"
	outPrefix="$2"
	suffix="${in##*.}"

	i="$3"
	shift 3
else
	in="$1"
	st="$2"

	outPrefix="${in%.*}"
	suffix="${in##*.}"
	shift 2
fi

trackBegin=0
	
for end in $*; do
	ffmpeg ${extra} -i "$in" -codec copy -ss "$trackBegin" -to "$end" "$(print_fname $i)"

	i=$(expr $i + 1)
	trackBegin="$end"
done

printf -v out "%s_%02d.%s" "${outPrefix}" "$i" "${suffix}"
ffmpeg ${extra} -i "$in" -codec copy -ss "$trackBegin" "$out"

