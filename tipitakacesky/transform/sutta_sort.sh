#!/bin/bash

function parse_fn()
{
        local dn=$(dirname "$1")
        local fn=$(basename "$1")
	if expr match "$fn" "[a-zA-Z]*[0-9.]*_.*" &>/dev/null; then
		local pref="${fn%%_*}"
		local nik="${pref%%[0-9]*}"
		local num="${pref##*[a-zA-Z]}"
		local maj="${num%%.*}"

		expr match "$num" '[0-9]*\.[0-9]*' &>/dev/null && \
			min="${pref##*.}"

		printf "%s|%-4s%03d.%03d|%s\n" "$dn" "$nik" "$maj" "$min" "$1" 
	else
		echo "$dn|$1|$1"
	fi
}

function sutta_sort()
{
	local sortk='2d'
	[ "$1" = '-d' ] && sortk='1d,2d' && shift

	while read fn;do
		parse_fn "$fn"
	done | sort -t '|' -k "$sortk" | cut -d '|' -f 3
}
export -f sutta_sort

function sutta_dir_sort()
{
	sutta_sort -d "$@"
}

# check to see if this file is being run or sourced from another script

function _is_sourced()
{
        # https://unix.stackexchange.com/a/215279
        [ "${#FUNCNAME[@]}" -ge 2 ] \
        && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
        && [ "${FUNCNAME[1]}" = 'source' ]
}

if ! _is_sourced; then
        sutta_sort "$@"
fi

