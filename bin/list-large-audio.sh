#!/bin/bash
[ -z "$min" ] && min=10
[ -z "$max" ] && max=56

find "$@" -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.mkv' -o -iname '*.mp4' | while read f; do br=$(ffprobe "$f" 2>&1|grep 'Audio:.*kb/s' -m 1|sed -e 's/.*\ \([0-9]*\)\ kb.*/\1/' ); [ -z "$br" ] && br=0; [ "$br" -gt "$max" -o "$br" -lt "$min" ] && echo -e "$br\t$f"; done
