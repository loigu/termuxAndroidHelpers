#!/bin/bash

[ -z "$parallel" ] && parallel=6

[  "$1" = -h -o -z "$1"] && echo -e "[export res=...] [parallel=$parallel debug=1] $0 [flist|dir] <-i|pattern>\n\tpattern ~ ${f%%.jpg}.png / small-$f / etc" && exit 1 

# wait -np pid
#

# file start end 
worker()
{
	head -n $3 "$1" | tail -n +$2 | while read from; do
		if [ "$pattern" != "-i" ]; then
			d=$(dirname "$from")
			f=$(basename "$from")
			to=$(eval echo "$pattern")
			to="$d/$to"
		else
			to='-i'
		fi
		
		resize-img.sh "${from}" "${to}"
	done
}

flist="$1"
if [ -d "$flist" ]; then
	tfl=$(mktemp "pr"_XXXXX.temp)
	ls "$flist"/*.jpg > $tfl
	flist="$tfl"
fi

export pattern='small-$to'
[ -n "$2" ] && export pattern="$2"

for i in $(seq $parallel); do
	lines=$(wc -l "$flist" | cut -d " " -f 1)
	incr=$(( $lines / $parallel ))
	[ -z "$start" ] && start=0 || start=$(( $end + 1 ))
	[ $i = $parallel ] && end=$lines || end=$(( $start + $incr ))
	worker "$flist" $start $end &
	pids="$pids $!"
done

wait $pids

[ -z "$debug" -a -f "$tfl" ] && rm "$tfl" 

