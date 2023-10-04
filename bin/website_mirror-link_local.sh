#!/bin/bash

cmd="$1"
base_dir=$(readlink -f "$2")
base_domain=$(basename "$base_dir")

function get_the_dots()
{
	slash=''
	dir=$(dirname "$1")
	[ "$dir" = "$base_dir" ] && echo -n '.\/' && return 0
	while [ "$dir" != "$base_dir" ]; do
		dir=$(dirname "$dir")
		echo -n "$slash.."
		slash='\/'
	done
}


function prettyfi()
{
	tmp=$(mktemp)
	find "$base_dir" -iname '*.html' |while read h;do
		html_prettyprint.py "$h" "$tmp" && mv "$tmp" "$h" -f &>/dev/null
	done
	rm "$tmp"
}

function process()
{
	#main index g index.html sometimes missing
	# src='' src=""
	grep -rie "['\"]http.*$base_domain/.*[\"']" "$base_dir" | cut -d : -f 1 | sort -u | while read h; do
		dots=$(get_the_dots "$h")
		sed -i "$h" \
			-e 's/\("https:\/\/'"$base_domain"'[^"]*\)\"/\1index.html"/g' \
			-e 's/\("https:\\\/\\\/'"$base_domain"'[^"]*\)\"/\1index.html"/g' \
			-e 's/https:\/\/'"$base_domain/$dots/g" \
			-e 's/https:\\\/\\\/'"$base_domain/$dots/g"
	done
}

$cmd

