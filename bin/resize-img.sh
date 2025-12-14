#!/bin/bash
# resize image

# split vertically: -crop 50%x100%
# remove 50pixels from all sides -shave 50
# 
if [ -z "$1" -o "$1" = -h ]; then
	echo "$(basename $0) from to
	from = dir ~ converts all to '\$to/\$(basename \$from)'
	to = -i in place
	export quality=$quality
	export res=$res (1200x-1, etc)
	export method=$method (use '-adaptive-resize' for text, for photo use '-resize')
	extra='-rotate 270 -shave 50'
	"
	exit 0
fi

[ -z "$quality" ] && quality=70
[ -z "$res" ] && res='35%'
[ -z "$method" ] && method='-adaptive-resize'

from=$(readlink -f "$1")
to="$2"
[ "$to" != -i ] && to=$(readlink -f "$2")
[ -d "$to" ] && ff=$(basename "$from") && to="$to/$ff"

bindir=$(readlink -f "$BASH_SOURCE")
bindir=$(dirname "$bindir")
source "${bindir}/common_include.sh"

function conv_it()
{
	local from="$1"
	local ftype=$(media_type "$1")
	[ "$ftype" = "image" ] || return 1

	if [ "$2" = "-i" ]; then
		local to=$(mktemp -u -p './')
	else
		local to="$2"
		local base=$(dirname "$to")
		[ -d "$base" ] || mkdir -p "$base"
	fi

	magick "$from" ${extra} $method $res -quality $quality "$to"
	local res="$?"
	if [ "$res" = 0 -a "$2" = "-i" ]; then 
		mv "$to" "$from" 
		res=$?
	fi

	return $res
}

if [ -f "$from" ]; then
	conv_it "$from" "$to"
elif [ -d "$from" ]; then
	old_pwd="$PWD"
	cd "$from"

	find ./ -type f | while read f; do 
		[ -d "$from" -a "$to" != "-i" ] && t="${to}/${f}" || t="$to"	
		conv_it "$f" "$t"
	done
	cd "$old_pwd"
else
	echo "unsupported from type (?link?)"
fi

