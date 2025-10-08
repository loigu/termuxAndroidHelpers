#!/bin/bash

start_toc()
{
    echo -e "<!DOCTYPE html>\n\
<html lang='en'>\n\
<head>\n\
    <meta charset='UTF-8'>\n\
    <title>$nikaya - TOC</title>\n\
    <style>\n\
        .index    {font-weight: 300;}\n\
    </style>\n\
</head>\n\
<body>"	 > "$contentsfile"

    echo -e "<h2 id='${nikaya}'>${nikaya}</h2>\n<br/>" >> "$contentsfile"
}

end_toc()
{
	print_footer >> "$contentsfile"
}

read_header()
{
	for i in $(seq 1 50); do
		[ "${en[$i]}" = '---' ] && return $(( $i + 1 ))

		if expr match "${en[$i]}" "[a-z]*:" &>/dev/null; then
			name=$(echo ${en[$i]} | cut -d ':' -f 1)
			cnt=$(echo ${en[$i]} | cut -d ':' -f 2)
			cnt=$(expr substr "$cnt" 2 "${#cnt}")

			eval $name=\'$(echo ${cnt}| tr "'" '"')\'
		else
			cnt="${cnt}<br\>${en[$i]}"
			eval $name=\'$(echo ${cnt}| tr "'" '"')\'
		fi
	done

	echo "invalid header, --- not found" >&2
	return 0
}


print_header()
{

    echo -e "<!DOCTYPE html>\n\
<html lang='en'>\n\
<head>\n\
    <meta charset='UTF-8'>\n\
    <title>${slug} - ${title}</title>\n\
    <style>\n\
        .en-text   {font-style: italic;}\n\
        .pli-text    {font-weight: bold;}\n\
	.en-intro	{font-weight: 200;}\n\
    </style>\n\
</head>\n\
<body>"	

    echo "<h3 id='${slug}'>${slug} - ${title}</h3>"

    echo "<p class='en-intro'> <b>description: </b>${description}</p>" 
    [ -n "$fetter" ] && echo "<p class='en-intro'> <b>fetter: </b>${fetter}</p>"
    [ -n "$theme" ] && echo "<p class='en-intro'> <b>theme: </b>${theme}</p>"
    [ -n "$tags" ] && echo "<p class='en-intro'> <b>tags: </b>${tags}</p>"
    [ -n "$commentary" ] && echo "<p class='en-intro'> <b>commentary: </b>${commentary}</p>"

    echo "<br/>"

    echo -e "<p class='index'><b><a href='${slug}.html#${slug}'>${slug} - ${title}</a></b>: ${description}</p>" >> "$contentsfile"

}

print_footer()
{
    echo '</body></html>'
}

print_line()
{
	local i=$1
     	local line="${pli[$i]}"

	[ -z "${line}" ] && return

	if expr match "${line}" "###" &>/dev/null; then
		echo "<h4 class='pli-text'>$(echo ${line} | tr -d '#')</h4>"
	else
		echo "<p class='pli-text'>${pli[$i]}</p>"
		echo "<p class='en-text'>${en[$i]}</p>"
	fi
}

if [ -z "$3" ]; then
	echo "$0 wordsofthebuddha/src/content htmldir nikaya"
	exit 1
fi

contentdir="$1"
htmldir="$2/$3"
nikaya="$3"
contentsfile="${htmldir}/_toc.html"

mkdir -p "$htmldir"
start_toc

# TODO: different header length
ls -1 "$contentdir/pli/$nikaya" | while read f; do
	outfile="${htmldir}/${f%%.md}.html"

	[ -f "$outfile" -a -z "$force" ] && continue
	unset pli
	unset en

	readarray -t pli < "$contentdir/pli/$nikaya/$f"
	readarray -t en < "$contentdir/en/$nikaya/${f%%.md}.mdx"

	if [ "${#pli[@]}" != "${#en[@]}" ]; then
		echo "$f: pli ${#pli[@]} lines != en ${#en[@]} lines" >&2
		continue
	fi
	
	read_header
	at=$?
	[ "$at" = 0 ] && continue

	print_header > "$outfile"
	while [ "$at" -lt "${#pli[@]}" ]; do
		print_line "$at" >> "$outfile"
		at=$(( $at + 1 ))
	done
	print_footer >> "$outfile"
done

end_toc

