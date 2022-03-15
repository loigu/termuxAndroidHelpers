#!/bin/bash

out="$1"
shift
[ -z "$out" -o -z "$1" -o "$out" = "-h" ] && \
	echo "$(basename $0) out.pdf images..." && \
	exit 1

convert "$@" -page a4 "$out"
