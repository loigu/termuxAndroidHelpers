#!/bin/bash

[ -z "$parallel" ] && parallel=6

[ -z "$2" -o "$1" = -h ] && echo [parallel=$parallel debug=1] $0 dir outfile.md5 && exit 1 

# wait -np pid
#

# file start end 
worker()
{
	head -n $3 "$1" | tail -n +$2 | while read f; do
		md5sum "$f" 
	done
}

flist=$(mktemp "$2"_XXXXX.temp)
find "$1" -type f > $flist

for i in $(seq $parallel); do
	lines=$(wc -l "$flist" | cut -d " " -f 1)
	incr=$(( $lines / $parallel ))
	[ -z "$start" ] && start=0 || start=$(( $end + 1 ))
	[ $i = $parallel ] && end=$lines || end=$(( $start + $incr ))
	worker "$flist" $start $end > "$2".$i &
	pids="$pids $!"
done

wait $pids

sort -k 2 --parallel=$parallel "$2".[0-9]* > "$2"
[ -z "$debug" ] && rm flist "$2".[0-9]*

