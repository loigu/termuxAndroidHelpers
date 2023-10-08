#!/bin/bash

# redownloads everything if there are no timestps
# changes link to local
function mirror_local()
{
	#redownloads everything if there.are no timestps
	wget -m -pk --compression=auto "$@"
}

# mirrors.web,skip existing files
# leaves links untouched
function mirror_skip_existing()
{
	wget -r -l inf -nc -c --compression=auto "$@"
}

#prettify html files recursively
function prettyfi()
{
	local tmp=$(mktemp)
	find "$base_dir" -iname '*.html' |while read h;do
		html_prettyprint.py "$h" "$tmp" && mv "$tmp" "$h" -f &>/dev/null
	done
	rm "$tmp"
}

function get_the_dots()
{
	local slash=''
	local dir=$(dirname "$1")
	local base_dir="$2"

	[ "$dir" = "$base_dir" ] && echo -n '.\/' && return 0
	while [ "$dir" != "$base_dir" ]; do
		dir=$(dirname "$dir")
		echo -n "$slash.."
		slash='\/'
	done
}

function link_local()
{
	local base_dir=$(readlink -f "$1")
	local base_domain=$(basename "$base_dir")

	#main index g index.html sometimes missing
	# src='' src=""
	grep -rie "['\"]http.*$base_domain/.*[\"']" "$base_dir" | cut -d : -f 1 | sort -u | while read h; do
		dots=$(get_the_dots "$h" "$base_dir")
		sed -i "$h" \
			-e 's/\("https:\/\/'"$base_domain"'[^"]*\)\"/\1index.html"/g' \
			-e 's/\("https:\\\/\\\/'"$base_domain"'[^"]*\)\"/\1index.html"/g' \
			-e 's/https:\/\/'"$base_domain/$dots/g" \
			-e 's/https:\\\/\\\/'"$base_domain/$dots/g"
	done
}

function help()
{
	echo -e "$0 cmd [args] \n\
		\tmirror_local, mirror_skip_existing [wget args] <domain/url>: local redownloads, converts links to local, skip existing does not convert links \n\
		\t\t-R mp3,pdf skip files with extension\n\
		\t\t--reject-regex '/dir/|/dir/|part-of-url\n\
		\tlink_local <dir>: transform links in dir to relative local - assuming <dir> is root domain name\n\
		\tprettyfi <dir> prettyfi html files in directory recursivelly\n"
}

cmd="$1"
shift
[ -z "$cmd" ] && cmd=help

$cmd "$@"

