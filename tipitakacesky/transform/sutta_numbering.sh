#!/bin/bash

function gen_list()
{
	local from="$1"
	local to="$2"
	local prefix="$3"

	rm "$to" -f
	find "$from" -iname "*.html" |while read f;do
	d=$(dirname "$f")
	fn=$(basename "$f")
	[ -n "$prefix" ] && fn="${prefix}_${fn}"
		echo -e "!!! mv '$f' '$d/$fn'\n----" >> "$to"
		head -n 100 "$f" | grep '<p' |head -n 5 | sed -e 's/&#160;/ /g' -e 's/<p[^>]*>\([^<]*\)<\/p>/\1/g'  >> "$to"
		echo "____" >> "$to"
	done
}

function gen_script()
{
	grep '!!! mv' "$1" | sed -e 's/!!! mv/mv/' > "$2"
	chmod +x "$2"
}

function usage()
{
	echo "usage: $(basename \"$0\") <list|gen|exec> from to [prefix]"
	exit 1

}

cmd="$1"
shift
[ -z "$1" -o -z "$2" ] && usage

case "$cmd" in
	list) gen_list "$@" ;;
	gen) gen_script "$@" ;;
	exec) bash "$@" ;;
	*) usage ;;
esac

