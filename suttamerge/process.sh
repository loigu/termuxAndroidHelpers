#!/bin/bash

sd=$(dirname "$BASH_SOURCE")

from=pdf
to=html
suffix='-strip.html'

[ "$1" = regen ] && sd/tohtml-s.sh "$from" "$to" "$sudfix"

export  id=0
find "$to"/* -maxdepth 0 -type d | while read d; do
	dn=${d##${to}/}
	id=$(( $id + 1 ))

	echo "<a id=\"$id\"/><h1>$dn<h1/>" >> "$to/single.html"
	echo "<a href=\"#$id\">$dn</a><br/>" >> "$to/toc-single.html"

	echo "<navPoint id=\"np_$id\" playOrder=\"$id\">
    <navLabel>
    <text>$dn</text>
    </navLabel>
    <content src=\"single.html#$id\"/>
    </navPoint>" >> "$to/toc-single.ncx"
    find "$d" -iname "*${suffix}" | while read sutta; do
	id=$(( $id + 1 ))
	name=$(basename "$sutta")
	name="${name%%.*}"

	echo "<a id=\"$id\"/><h2>${name}<h2/>" >> "$to/single.html"
	echo "<a href=\"#$id\">$name</a><br/>" >> "$to/toc-single.html"

	cat "$sutta" >> "$to"/single.html
	echo "<navPoint id=\"np_$id\" playOrder=\"$id\">
    <navLabel>
    <text>$name</text>
    </navLabel>
    <content src=\"single.html#$id\"/>                         </navPoint>" >> "$to/toc-single.ncx"

    	echo "<a id=\"$id\"/><h2>${name}<h2/>" >> "$to/dn.html"
    	cat "$sutta${suffix}" >> "$to/$dn.html"

    	echo "<a href=\"$id\">${name}</a><br/>" >>"$to/toc-$dn.html"
    	echo "<navPoint id=\"np_$id\" playOrder=\"$id\">
    <navLabel>                                                 <text>$name</text>
    </navLabel>
    <content src=\"single.html#$id\"/>                         </navPoint>" >> "$to/toc-$d.ncx"
    done
    id=$(( $id + 1 ))
done

