#!/bin/bash
# copy files in name order - ensure it is in the same order on fat (for stupid mp3 players)

IN=$(cd "$1" && pwd)
OUT=$(cd "$2" && pwd)

[ -z "$IN" -o -z "$OUT" -o "$IN" = '-h' ] && echo $(basename "$0") '<indir> <outdir>' && exit

copy_dir()
{
	local target="$2/$1"
	[ -d "$target" ] || mkdir -p "$target"

	find "$1" -xdev -maxdepth 1 -type f | sort | while read f; do
		cp "$f" "$target"
		sync -f "$target"
	done
}

OLD_PWD="$(pwd)"
rel_path=""

cd "$IN"
find ./ -xdev -type d | sort | while read d; do
	copy_dir "$d" "$OUT"
done
cd "$OLD_PWD"
