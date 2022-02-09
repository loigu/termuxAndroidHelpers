#!/bin/bash
f="$1"
t="$2"
[ -z "$1" -o "$1" = '-h' ] && echo "usage: $0 from.jpg [to.pdf]" && exit 1
[ -z "$2" ] && t="${f%%.jpg}.pdf"

pages2pdf.sh "$t" "$f"

