#!/bin/bash

SCRIPT_PATH=$(readlink -f "$BASH_SOURCE")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

function print_header()
{
	local title="$1"
	echo -e "<!DOCTYPE html>\n\
		<html lang='si'>\n\
			<head>\n\
				<meta charset='UTF-8'>\n\
				<title>${title}</title>\n\
				<style>\n"
	cat "$SCRIPT_DIR/style.css"
	echo -e "
				</style>\n\
			</head>\n\
			<body>\n"
}

function print_footer()
{
	echo '</body></html>'
}

function process_file()
{
	local path="$1"
	local file="$2"

	if [ "${standalone}" = "1" ]; then
		local out="${outprefix}/$path/${file%%.json}.html"
	else
		local out='-'
	fi
	
	python3 "$SCRIPT_DIR/json2html.py" "$file" "$out"
}

function process_dir()
{
	local dir="$2"
	local header="$dir"
	local path="$1/$2"
	local level="$3"

	[ "$level" = 1 ] && header="${header#[0-9]* }"

	if [ "${standalone}" != "1" ]; then
		echo -e "\n\n<h${level} id='${dir}' class='sutta-title'>${header}</h${level}>\n"
	else
		mkdir -p "${outprefix}/$path"
	fi

	cd "$dir"
	
	ls -1 . | sort | while read f; do
		if [ -f "$f" ]; then
			process_file "$path" "$f"
		elif [ -d "$f" ]; then
			process_dir "$path" "$f" $(( $level + 1 ))
		else
			echo "wtf, $path/$f nor file nor dir" >&2
		fi
	done

	cd ..
}


old_pwd="$PWD"

if [ -z "$2" -o "$1" = "-h" ]; then
	echo -e $(basename "$0")" <base_nikaya_dir> <outprefix | outfile>\n\
		\texport standalone=1"
	exit 1
fi

in="${1%%/}"
if [ "${standalone}" = "1" ]; then
	outprefix=$(readlink -f "$2")
	process_dir . "$in" 1
else
	print_header "${in#[0-9]* }" > "$2"
	process_dir . "$in" 1 >> "$2"
	print_footer >> "$2"
fi

cd "$old_pwd"



