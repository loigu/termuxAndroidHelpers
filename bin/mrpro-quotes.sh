#!/bin/bash

[ -z "$1" ] && from=backup.mrpro || from="$1"
[ -z "$2" ] && to=mrpro-quotes.txt || to="$2"

if [ "$1" = '-h' ] || [ ! -f "$from" ]; then
	echo "$0 backup.mrpro out.txt"
	exit 1
fi

#TODO: join multiline
7z e -y "$from" '*/4.tag' && \
        echo 'SELECT book,filename,bookmark,note,original from
 notes;' | sqlite3 4.tag > "$to" && \
        rm 4.tag

