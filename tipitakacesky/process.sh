#!/bin/bash

script_dir=$(dirname "$BASH_SOURCE")

if [ "$1" = -f ]; then
	regen=y
	shift 
fi

from="$1"
to="$2"
suffix='-strip.html'
[ -n "$3" ] && suffix="$3"

[ "$regen" = y ] && "${script_dir}/tohtml-s.sh" "$from" "$to" "$suffix"


s="$to/Tipitaka cesky"
si="$s.html"
sit="$s-toc.ncx"
sith="$s-toc.html"

rm -f "$si" "$sit" "$sith"

export  id=0
find "$to"/* -maxdepth 0 -type d | while read d; do
	dn=${d##${to}/}
	id=$(( $id + 1 ))

	echo "<a id=\"$id\"/><h1>$dn<h1/>" >> "$si"
	echo "<a href=\"#$id\">$dn</a><br/>" >> "$sith"
	echo "<navPoint id=\"np_$id\" playOrder=\"$id\">
    <navLabel>
    <text>$dn</text>
    </navLabel>
    <content src=\"$si#$id\"/>
    </navPoint>" >> "$sit"

    nik="$to/$dn.html"
    nikt="$to/$dn-toc.ncx"
    nikth="$to/$dn-toc.html"

    rm -f "$nik" "$nikt" "$nikth"

    find "$d" -iname "*${suffix}" | while read sutta; do
    #TODO SEPATRAETE ID FOR EACH FILE
	id=$(( $id + 1 ))
	name=$(basename "$sutta")
	name="${name%%${suffix}}"

	echo "<a id=\"$id\"/><h2>${name}<h2/>" >> "$si"
	cat "$sutta" >> "$si"

	echo "<a href=\"#$id\">$name</a><br/>" >> "$sith"
	echo "<navPoint id=\"np_$id\" playOrder=\"$id\">
    <navLabel>
    <text>$name</text>
    </navLabel>
    <content src=\"$si#$id\"/>                         </navPoint>" >> "$sit"

    	echo "<a id=\"$id\"/><h2>${name}<h2/>" >> "$nik"
    	cat "$sutta" >> "$nik"

    	echo "<a href=\"#$id\">${name}</a><br/>" >>"$nikth"
    	echo "<navPoint id=\"np_$id\" playOrder=\"$id\">
    <navLabel>                                                 <text>$name</text>
    </navLabel>
    <content src=\"$nik#$id\"/>                         </navPoint>" >> "$nikt"
    done
    id=$(( $id + 1 ))
done

for toc in "$to"/*.ncx; do
	base="${toc%%-toc.ncx}"
	name=$(basename "$base")
	content="$base.html"
	index="${base}-toc.html"
	full="${base}-full.html"

	head='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>'"$name"'</title>
</head>
<body>'

	end="</body></html>"


	echo "$head" > "$full"
	cat "$index" >> "$full"
	echo "<br/" >> "$full"
	cat "$content" >> "$full"
	echo "$end" >> "$full"
done

