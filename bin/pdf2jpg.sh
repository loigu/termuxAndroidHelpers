#!/bin/bash
f="$1"
t="$2"
[ -z "$res" ] && export res='1920x1080'
[ -z "$1" -o "$1" = '-h' ] && echo "usage: [res='1024x640'] $0 from.pdf [to.jpg]" && exit 1
[ -z "$2" ] && t="${f%%.pdf}.jpg"

convert -density 300 -size "$res" "$f" "$t"

