#!/bin/bash
#

script_dir=$(dirname "${BASH_SOURCE}")

function clean_junk()
{
	# use normal spaces, remove artificial linebreaks
	# remove div & paragraph style
	# remove all other page breaks & divs
	# remove styles
	# remove usage & empty paragraphs
	
	sed -e 's/&#160;/\ /g' -e 's/<br\/>//g' | \
	sed -e 's/div\(.*\)style="position:relative;width:[0-9]*px;height:[0-9]*px;\(.*\)"/div\1\ \2/g' | \
	sed -e 's/p\ style="position:absolute;top:[0-9]*px;left:[0-9]*px;white-space:nowrap"\ \(class="ft[0-9]*"\)/p \1/g' | \
	sed -z -e 's/<\/p>\n[^\n]*<\/div>\n[^\n]*<!-- Page [0-9]* -->\(\n[^\n]*\)\{6\}\n<p[^>]*>//g' | \
	sed -z -e 's/<a name="[0-9]*"><\/a>\(\n[^\n]*\)\{3\}\(\n[^\n]*.ft[0-9]*[^\n]*\)*\(\n[^\n]*\)\{2\}//g' | \
	sed -z -e 's/[a-zA-Zř]*\( určen\)*\( jen\)*\( pouze\)* k soukromému užití[0-9]*//g' -e 's/[\ \t\n]*[[:space:]]*<p[^>]*>[[:space:]]*[\ \t\n]*<\/p>[\ \t]*//g'
	# -e '/^[[:space:]]*$/d'

}

function gen_html()
{
	from=$(readlink -f "$1")
	to=$(readlink -f "$2")
	cd "$from"
	find . -iname "*.pdf" |while read f;do
		dn=$(dirname "$f")
		mkdir -p "$to/$dn"
		pdftohtml -noframes -q -p -s -nodrm -i -stdout "$f" "$to/${f%%.pdf}.html"
	done
}

function join_html()
{
echo '<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
<title>Tipitaka cesky</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta name="generator" content="pdftohtml 0.36"/>
<meta name="date" content="'"$(date '+%F %H:%m')"'"/>
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
h1, h2 {page-break-before: always;}
-->
</style>
</head>
<body  vlink="blue" link="blue">' > "$targ"
nik=''
. "$script_dir/sutta_sort.sh"

find */ -iname '*.html' | sutta_sort -d | while read f;do 
	nnik=${f%%/*}
	if [ "$nik" != "$nnik" ];then 
		echo -e "<h1>$nnik</h1>\n<div class=\"nikaya\">\n" >> "$targ"
		nik="$nnik"
		tail="</div> <!--end of $nnik nikaya-->\n"
	else
		tail=''
	fi
	
	title=$(grep '<title>' "$f" |sed -e 's/.*>\([^<]*\)<.*/\1/')

	fn=$(basename "$f")
	expr match "$fn" "[a-zA-Z]*[0-9.]*_.*" &>/dev/null && \
		title="$(echo "$fn" | cut -d '_' -f 1) - $title"

	echo -e "<h2>$title</h2>\n<div class=\"sutta-div\">" >> "$targ"
	tail="$tail</div><!--end of sutta $title-->\n"

	pl=$(grep "Page 1" "$f"  -n  |head -n 1 | cut -d : -f 1)
	ll=$(grep "</body" "$f"  -n  |tail -n 1 | cut -d : -f 1)
	# targ="${f%%.html}-h2.html"; head -n  $(( "${p}" - 1 )) "$f" > "$targ"
	head -n $(( $ll - 1 )) "$f" | tail -n +$(( $pl + 1 ))  >> "$targ"
	echo -e "$tail" >> "$targ"

done

echo '</body>
</html>
' >> "$targ"

cat "$targ" | clean_junk > "_$targ"
mv "_$targ" "$targ"

}

function gen_doc()
{
	pandoc "$source" --toc -o "${targ}"
}
function gen_epub()
{
	local res="$script_dir/res"

	pandoc --toc --toc-depth=2 --epub-metadata="${res}/metadata.yaml" --epub-cover-image="$res/cover.jpg" --css="$res/book.css" -o "${targ}" "$source"
}

# check to see if this file is being run or sourced from another script

function _is_sourced()
{
        # https://unix.stackexchange.com/a/215279
        [ "${#FUNCNAME[@]}" -ge 2 ] \
        && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
	&& [ "${FUNCNAME[1]}" = 'source' ]
}

function _main()
{
	for targ in "$@"; do
		ext="${targ##*.}"
		[ -z "$source" ] && source="${targ%%.*}.html"

	case "$ext" in
		gen) gen_html ;;
		html) join_html && source="$targ" ;;
		epub) gen_epub ;;
		*) gen_doc ;;
	esac
	done
}

if ! _is_sourced; then
	_main "$@"
fi

# arr=()
# while read f;do  arr+=( "$f" ); done<list
# pandoc "${arr[@]}" -o all.docx


