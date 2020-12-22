#!/bin/bash
# resize image

[ -z "$quality" ] && quality=70
[ -z "$res" ] && res='35%'
[ -z "$method" ] && method='-adaptive-resize'

if [ -z "$1" ]; then
	echo "$(basename $0) from to
	from = dir - list all
	export quality=$quality
	export res=$res
	export method=$method (use '-adaptive-resize' for text, for photo use '-resize')
	extra='-rotate 270'
	"
	exit 0
fi

#todo: dir recognition
convert "$1"  $method $res -quality $quality "$2"

