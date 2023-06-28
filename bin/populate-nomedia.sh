#!/bin/bash

[ -z "$1" -o "$1" = "-h" ] && echo -e $(basename "$0")" [-rm] dir1 dir2 ...\n\t-rm for delete the .nomedia" && exit 

function add() {
find "$@" -type d | while read d; do
	[ ! -f "$d/.nomedia" ] && touch "$d/.nomedia"
done
}

function del() {
find "$@" -iname .nomedia -exec rm '{}' \;
}

if [ "$1" = '-rm' ]; then
	shift
	del "$@"
else
	add "$@"
fi

