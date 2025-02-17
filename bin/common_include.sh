#!/bin/bash

function media_type()
{
	local e="${1##*.}"
	case "$e" in
		m4a)
			echo audio
			;;
		*)
			local mt=$(file --mime-type -F ';'  "$1" | cut -d ";" -f 2 | cut -d '/' -f 1 | tr -d ' ')
			;;
	esac

	if [ "$mt" = "video" ]; then
		ffprobe "$1" 2>&1 |grep 'Stream.*Audio' -q && mt="audio"
		ffprobe "$1" 2>&1 |grep 'Stream.*Video' -q && mt="video"
	fi

	echo $mt
}

export -f media_type

