#!/bin/bash

sd=$(dirname "${BASH_SOURCE}")

base="$1"
prefix=html
suffix='-strip.html'
[ -n "$2" ] && prefix="$1"
[ -n "$3" ] && suffix="$2"

find "${base}/*" -maxdepth 0 -type d | while read d; do
    find "$d" -iname '*.pdf'|while read sutta; do
	n="${sutta##${base}/}"
	h="$prefix/${n%%.*}.html"
	s="${prefix}/$n%%.*}${suffix}"
	sd=$(dirname "$h")

	mkdir -p "${sd}"
    	# pdftohtml -noframes -q -p -s -nodrm -i "$sutta" "$sutta.html" && bash "$sd/suttastrip.sh" "$h" "$s" # body

	pdftotext -nopgbrk -htmlmeta "$sutta" "${h}" && \
	"$sd/suttastrip.sh" "$h" "$s" pre
    done
done

