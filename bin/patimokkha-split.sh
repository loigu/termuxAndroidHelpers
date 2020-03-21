#!/bin/bash

in="$1"
rulePrefix="$2"
ruleIndex="$3"
shift 3

[ ! -f "$in" -o -z "$rulePrefix" -o -z "$ruleIndex" ] && echo -e "$(basename $0) <infile> <rulePrefix> <ruleIndex>\n\t $(basename $0) Track 08.mp3 NP 11" && exit 1

split-mp3.sh -m "$in" "$rulePrefix" "$ruleIndex" "$@"

for f in ${rulePrefix}*.mp3; do 
	id3v2 -a 'ajahn khemmanando' -A 'per rule patimokkha' -t "${f%%.*}" "$f"
done

