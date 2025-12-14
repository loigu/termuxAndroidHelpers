#!/bin/bash
# localize refs in html files

[ -z "$1" -o "$1" = -h ] && echo "UNTESTED $0 basedir url" && exit 1

base=$(readlink -f "$1")
url="$2"
old="$PWD"

get_level()
{
	i=0
	local cur="$1"
	while true; do
		[ "$cur" = "$base" ] && return $i
		[ "$cur" = '.' -o "$cur" = '/' ] && return -1
		cur=$(dirname "$cur")
		i=$(( $i + 1 ))
	done
}

get_base()
{	
	cur="$1"
	[ "$cur" = "$base" ] && echo ".\/" && return 0

	while [ "$cur" != "$base" ]; do
		echo -n '..\/'
		cur=$(dirname "$cur")
	done
	return 0
}

cd "$base"
s_url=$(echo $url | sed -e "s/\//\\\\\//g" -e 's/\./\\\./g')
grep -Frl "$url" . | while read f; do
	d=$(readlink -f "$f")
	d=$(dirname "$d")
	b=$(get_base "$d")
	sed -e "s/https\?:\/\/${s_url}\//$b/g" -i "$f"
done
cd "$old"
