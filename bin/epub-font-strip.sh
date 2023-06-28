#!/bin/bash

FONTDIR="/storage/emulated/0/Fonts/"
[ "$1" = -f ] && FONTDIR=$(readlink -f "$2") && shift 2


[ "$1" = -h ] && echo $(basename "$0")" [-f fontdir] in out" && exit 0

in="$1"
out="$2"
[ -z "$out" ] && out="$in"
out=$(readlink -f "$out")
tmp=$(mktemp -d)
o=$(pwd)

unzip "$1" -d "$tmp"
[ ! -d "$FONTDIR" ] && mkdir "$FONTDIR"
cp -n "$tmp/OEBPS/fonts/"* "$FONTDIR"
rm -rf "$tmp/OEBPS/fonts/"

rm -f "$out"; cd "$tmp"
zip -9rm "$out" *
cd "$o"
rmdir "$tmp"

