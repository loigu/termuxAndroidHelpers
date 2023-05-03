#!/bin/bash

[ -z "$1" -o "$1" = "-h" ] && echo $(basename "$0")" dir1 dir2 ..." && exit 

find "$@" -type d |while read d; do
	[ ! -f "$d/.nomedia" ] && touch "$d/.nomedia"
done
