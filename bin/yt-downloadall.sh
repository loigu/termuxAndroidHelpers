#!/bin/bash
list=$1
ok=ok
q=$2

[ -z "$1" ] && echo "usage $(basename $0) yt_url_
ist [quality]" && exit 1

[ -z "$2" ] && q=43 

for f in $(cat $list); do 
	grep -q $f $ok && continue
	youtube-dl $f -f $q
	[ $? = 0 ] && echo $f >> ok
done

