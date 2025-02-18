#!/bin/bash

out="$1"
shift
[ -z "$out" -o -z "$1" -o "$out" = "-h" ] && \
	echo "[page=a4] $(basename $0) out.pdf images..." && \
	exit 1

[ -z "$page" ] && page=a4
magick "$@" -page "$page" "$out"
