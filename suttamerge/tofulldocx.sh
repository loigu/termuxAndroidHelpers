#!/bin/bash
#
targ=all.html

function gen_html()
{
	from=$(readlink -f "$1")
	to=$(readlink -f "$2")
	cd "$from"
	find . -iname "*.pdf" |while read f;do
	dn=$(dirname "$f")
	mkdir -p "$to/$dn"
	pdftohtml -noframes -q -p -s -nodrm -i "$f" "$to/${f%%.pdf}.html"; done
}

# todo: grep from first file
echo '<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
<title>Tipitaka cesky</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="generator" content="pdftohtml 0.36"/>
<meta name="date" content="2023-01-11T11:09:55+00:00"/>
<style type="text/css">
<!--
.xflip {
    -moz-transform: scaleX(-1);
    -webkit-transform: scaleX(-1);
    -o-transform: scaleX(-1);
    transform: scaleX(-1);
    filter: fliph;
}
.yflip {
    -moz-transform: scaleY(-1);
    -webkit-transform: scaleY(-1);
    -o-transform: scaleY(-1);
    transform: scaleY(-1);
    filter: flipv;
}
.xyflip {
    -moz-transform: scaleX(-1) scaleY(-1);
    -webkit-transform: scaleX(-1) scaleY(-1);
    -o-transform: scaleX(-1) scaleY(-1);
    transform: scaleX(-1) scaleY(-1);
    filter: fliph + flipv;
}
-->
</style>
</head>
<body bgcolor="#A0A0A0" vlink="blue" link="blue">' > "$targ"

nik=''
find */ -iname '*.html'|while read f;do 
	nnik=${f%%/*}
	if [ "$nik" != "$nnik" ];then 
		echo "<h1>$nnik</h1>" >> "$targ"
		nik="$nnik"
	fi

	title=$(grep '<title>' "$f" |sed -e 's/.*>\([^<]*\)<.*/\1/')
	echo "<h2>$title</h2>" >> "$targ"

	pl=$(grep "Page 1" "$f"  -n  |head -n 1 | cut -d : -f 1)
	ll=$(grep "</body" "$f"  -n  |tail -n 1 | cut -d : -f 1)
	# targ="${f%%.html}-h2.html"; head -n  $(( "${p}" - 1 )) "$f" > "$targ"
	head -n $(( $ll - 1 )) "$f" | tail -n +$(( $pl + 1 ))  >> "$targ"

	#tail -n  +$(( "$p" + 1 )) "$f" >> "$targ"
done

echo '</body>
</html>
' >> "$targ"
pandoc "$targ" -o "${targ%%.*}.docx"

# find . -iname '*-h2.html' -o -iname '*-head.html' |sort>list
# arr=()
# while read f;do  arr+=( "$f" ); done<list
# pandoc "${arr[@]}" -o all.docx


