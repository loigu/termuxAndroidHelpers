#!/bin/bash
cd Download/shrink/ || exit 1
mkdir '../done' '../shrunk'
ls -1 *.mp3 *.m4a | while read f; do
	clean-audio.sh "$f" ../shrunk/ && \
		mv "$f" "../done/"
	
done
