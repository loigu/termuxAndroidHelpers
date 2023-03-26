#!/bin/bash

from=$(readlink -f "$1")
to=$(readlink -f "$2")
pow="$PWD"

cd "$from"
find . -type d|while read d;do  mkdir -p "$to/$d"; done
find . -type f|while read d;do ln "$d" "$to/$d"; done
cd "$pow"

