#!/bin/bash

IN="$1"
OUT="$2"

[ -z "$IN" -o -z "$OUT" -o "$IN" = '-h' ] && echo $(basename "$0") '<indir> <outdir>' && exit

copy_dir()
{
	local old_path="$rel_path"

	cd "$1"
	[ -n "$rel_path" ] && rel_path="$rel_path/$1" || rel_path="$1"
	[ -d "$OUT/$rel_path" ] || mkdir -p "$OUT/$rel_path"
	sync

	ls -1 | while read item; do
		[ -f "$OUT/$rel_path/$item" ] && continue

		[ -d "$item" ] && copy_dir "$item"
		[ -f "$item" ] && cp "$item" "$OUT/$rel_path"  && sync
	done

	cd ..
	rel_path="$old_path"
}

OLD_PWD="$(pwd)"
rel_path=""

cd "$IN"
copy_dir .
cd "$OLD_PWD"

