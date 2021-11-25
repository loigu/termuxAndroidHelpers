#!/bin/bash
cd ~/Download/shrink/ || exit 1
mkdir -p 'done' 'shrunk'
ls -1 *.mp3 *.m4a 2>/dev/null | while read f; do
	clean-audio.sh "$f" "shrunk/" </dev/null 2>>debug.txt && \
		mv "$f" "done/"
done
