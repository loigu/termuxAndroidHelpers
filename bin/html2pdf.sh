#!/bin/bash

[ -z "$1" ] && echo "$0 from to [additional pandoc flags" && exit 0

from="$1"
to="$2"
shift 2

pandoc "$from" --toc --toc-depth=4 -o "$to" --pdf-engine xelatex "$@"

