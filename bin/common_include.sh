#!/bin/bash

function media_type()
{
	local ext="${1##*.}"
	case "$ext" in
		m4a)
			echo audio
			;;
		*)
			file --mime-type -F ';'  "$1" | cut -d ";" -f 2 | cut -d '/' -f 1 | tr -d ' '
			;;
	esac
}
export -f media_type
