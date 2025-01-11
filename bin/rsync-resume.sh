#!/bin/bash

mode="--append-verify"
[ "$1" = "-n" ] && mode="--append" && shift

[ -z "$2" -o "$1" = "-h" ] && echo -e $(basename "$0")" [-n] <in> <out>\n\t-n\t don't verify checksum when appending" && exit

rsync -avz --compress-level=9 -P ${mode} "$@"
