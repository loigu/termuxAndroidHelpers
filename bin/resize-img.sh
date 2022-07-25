#!/bin/bash
# resize image

[ -z "$quality" ] && quality=70
[ -z "$res" ] && res='35%'
[ -z "$method" ] && method='-adaptive-resize'

if [ -z "$1" ]; then
	echo "$(basename $0) from to
	from = dir ~ converts all to '\$to/\$(basename \$from)'
	export quality=$quality
	export res=$res
	export method=$method (use '-adaptive-resize' for text, for photo use '-resize')
	extra='-rotate 270'
	"
	exit 0
fi

from="$1"
to=$(readlink -f "$2")
old_pwd="$PWD"

if [ -f "$from" ]; then
	convert "$from"  $method $res -quality $quality "$to"
elif [ -d "$from" ]; then
	base=$(basename "$from")
	mkdir -p "$to/$base"
	cd "$from"

	find . -type f | while read f; do 
		p="$base"/$(dirname "$f")
		[ -d "$to/$p" ] || mkdir -p "$to/$p"
		convert "$f" $method $res -quality $quality "$to/$base/$f"
	done
else
	echo "unsupported from type (?link?)"
fi


