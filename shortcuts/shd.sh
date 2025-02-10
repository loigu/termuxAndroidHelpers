#!/bin/bash

export extra="-v 16 -y"

cd ~/Download/shrink/ || exit 1
mkdir -p 'done' 'shrunk'

ls -1 *.mp3 *.m4a *.opus 2>/dev/null | while read f; do
	echo "$f:"
	recode-media.sh "$f" "shrunk/" </dev/null  && \
		mv "$f" "done/"
done
