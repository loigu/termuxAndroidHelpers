#!/bin/bash
#
#to be run in root json dir

export SCRIPT_PATH=$(readlink -f "$BASH_SOURCE")
export SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

[ "$1" = -h ] && echo "gen_html=1 gen_epub=0 $(basename '$1')" && exit 1

export standalone=0
export pli=1
for pli in 1 0; do
	echo -e '001 dn 3\n\
002 mn 4\n\
003 sn 5 \n\
004 an 4' | while read di name hi; do
		[ $pli = 1 ] && name="$name-pli"
		name="$name-sin.html"
		dir=$(ls -d $di*)
		export header_tag="h${hi}"
		[ "$gen_html" = 1 ] && "$SCRIPT_DIR/iter_dir.sh" "$dir" "$name"
		[ "$gen_epub" = 1 ] && pandoc --toc-depth $hi "$name" -M "title=${dir#[0-9]* }" -o "${name%%.html}.epub"
	done

	# 005 khuddaka nikāya:
	cd 005*
	echo -e '001 kp 2\n\
002 dhp 2\n\
003 ud 3\n\
004 iti 4\n\
005 snp 3\n\
006 vimv 3\n\
007 petv 3\n\
008 thag 4\n\
009 thig 3' | while read di name hi; do
		[ $pli = 1 ] && name="$name-pli"
		name="../$name-sin.html"
		dir=$(ls -d $di*)
		title="${dir#[0-9]* }"
		export header_tag="h${hi}"
		[ "$gen_html" = 1 ] && "$SCRIPT_DIR/iter_dir.sh" "$dir" "$name"
		[ "$gen_epub" = 1 ] && pandoc --toc-depth $hi "$name" -M "${title}" -o "${name%%.html}.epub"
	done
	cd ..
done

