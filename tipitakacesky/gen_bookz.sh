#!/bin/bash
#

script_dir=$(dirname "${BASH_SOURCE}")
res="$script_dir/res"

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


cache_file=".sutta_list.cache"
function convert_pdf()
{
	local from=$(readlink -f "$1")
	local to=$(readlink -f "$2")
	local start="$PWD"
	cd "$from"
	find . -iname "*.pdf" |while read f;do
		dn=$(dirname "$f")
		mkdir -p "$to/$dn"
		pdftohtml -noframes -q -p -s -nodrm -i -stdout "$f" "$to/${f%%.pdf}.html"
	done

	cd "$start"
}

function convert_docx()
{	
	local from=$(readlink -f "$1")
	local to=$(readlink -f "$2")
	local start="$PWD"
	cd "$from"

	find . -iname "*.docx" | while read f;do 
		fn=$(basename "$f")
		pref="${fn%%_*}"
		name="${fn%.*}"; name=${name##*_}
		title="${pref} - ${name}"

		pandoc --standalone --metadata title="$title" "$f" -o "${to}/${f%%.docx}.html"
	done

	cd "$start"
}

function gen_html()
{
	convert_pdf pdf html
	convert_docx docx html

	rm -f "$cache_file"
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
h1, h2, h3, h4 {page-break-before: always;}
-->
</style>
</head>
<body  vlink="blue" link="blue">' > "$targ"
	prev_nik=''
	prev_maj=''

	#
	sutta_level=2
	if [ "$multilevel_toc" = 'y' ]; then
		sutta_level=4
	fi

if [ "$use_cache" != 'y' ] || [ ! -f "$cache_file" ]; then
	. "$script_dir/sutta_sort.sh"
	find */ -iname '*.html' | sutta_sort -d > "$cache_file"
fi

while read f;do 
	fn=$(basename "$f")
	pref="${fn%%_*}"
        nik="${pref%%[0-9]*}"

	# new nikaya
	if [ "$nik" != "$prev_nik" ];then 
		#we got multilevel toc started
		[ -n "$prev_maj" ] && \
			echo "</div> <!--end of $prev_nik$prev_maj -->" >> "$targ" && \
			prev_maj=''

		# we got started nikaya
		[ -n "$prev_nik" ] && \
			echo "</div> <!--end of $prev_nik -->" >> "$targ"
		dn=$(dirname "${f}")
		echo -e "<h1 id=\"$nik\">${dn}</h1>\n<div class=\"nikaya-div\">\n" >> "$targ"
		prev_nik="$nik"
	fi
	
	if [ "$multilevel_toc" = 'y' ]; then
		num="${pref##*[a-zA-Z]}"
		maj="${num%%.*}"        
		min=0
		expr match "$num" '[0-9]*\.[0-9]*' &>/dev/null && \
			min="${num##*.}"
		
		# non-zero min ~ multilevel - subc change
		if [ "$min" != 0 -a "$maj" != "$prev_maj" ]; then
			# got started one
			[ -n "$prev_maj" ] && \
				echo "</div> <!--end of $nik$prev_maj -->" >> "$targ"

			##SN - level 3,other level 2
			[ "$nik" = "SN" ] && sublevel=3 || sublevel=2
			echo -e "<h$sublevel id=\"$nik$maj\">${maj}</h$sublevel>\n<div class=\"sublevel$sublevel-div\">\n" >> "$targ"

			prev_maj="$maj"
		fi
	fi

	# name=$(grep '<title>' "$f" |sed -e 's/.*>\([^<]*\)<.*/\1/')
	name="${fn%.*}"; name=${name##*_}
	title="${pref} - ${name}"
	echo -e "<h${sutta_level} id=\"$pref\">$title</h${sutta_level}>\n<div class=\"sutta-div\">" >> "$targ"

	# docx conversion
	pl=$(grep '</header>' "$f" -n |head -n 1 |cut -d : -f 1)

	#pdf conversion
	[ -z "$pl" ] && \
		pl=$(grep "Page 1" "$f"  -n  |head -n 1 | cut -d : -f 1)
	ll=$(grep "</body" "$f"  -n  |tail -n 1 | cut -d : -f 1)
	# targ="${f%%.html}-h2.html"; head -n  $(( "${p}" - 1 )) "$f" > "$targ"
	head -n $(( $ll - 1 )) "$f" | tail -n +$(( $pl + 1 ))  >> "$targ"
	echo "</div><!--end of sutta $title-->" >> "$targ"

done < "$cache_file"

# assume last nikaya SN ~ has subchapters
[ "$multilevel_toc" = 'y' ] && echo '</div>' >> "$targ"

# assume some nikaya div
echo -e '</div>\n</body>\n</html>\n' >> "$targ"

cat "$targ" | clean_junk > "_$targ"
mv "_$targ" "$targ"

}

function gen_doc()
{
	pandoc "$source" --toc --toc-depth=4 --metadata-file="$res/metadata.yaml" -o "${targ}"
}

function gen_epub()
{
	pandoc --toc --toc-depth=4  --metadata-file="${res}/metadata.yaml" --metadata "subtitle: export $(date +%y-%m-%d)" -M "subtitle='aktuální verze: https://bit.ly/tipitakacesky'"  --epub-cover-image="$res/cover.jpg" --css="$res/book.css" -o "${targ}" "$source"
}

function gen_pdf()
{
	pandoc --metadata-file="$res/pdf.yaml"  -M "subtitle=$(date '+%Y-%m-%d %H:%m')" --toc --toc-depth=4 -o "tipitaka_cesky.pdf"  --top-level-division part --pdf-engine xelatex \
	anguttara-nikaya-cesky[0-9]*.docx \
	digha-nikaya-cesky[0-9]*.docx \
	'majjhima_nikaya česky 1 - 50 '[0-9]*.docx \
	'majjhima_nikaya česky 51 - 100 '[0-9]*.docx \
	'majjhima_nikaya česky 101 - 152 '[0-9]*.docx \
	samyutta-nikaya-cesky[0-9]*.docx \
	khuddakapatha.docx dhammapada.docx \
	udana[0-9]*.docx itivuttaka.docx \
	suttanipata-cesky[0-9]*.docx \
	theraghata-cesky[0-9]*.docx \
	petavatthu-cesky[0-9]*.docx $extra

	pandoc --toc --toc-depth=4 --top-level-division part --pdf-engine xelatex \
		--metadata-file="$res/vinaya.yaml"  -M "subtitle=$(date '+%Y-%m-%d %H:%m')" \
		--css="$res/book.css" -o vinaya-pribehy.pdf \
		vinaya_pitaka-pribehy[0-9]*.docx $extra
		
}

function gen_print_pdf()
{
	for s in Anguttara Digha Samyutta; do
		fn=$(echo $s |tr '[:upper:]' '[:lower:]')
		pandoc --metadata-file="$res/pdf.yaml" \
			-M "title=$s nikaya česky" \
			-M "subtitle=$(date '+%Y-%m-%d %H:%m')" \
			--toc --toc-depth=4 \
			-o "${fn}_nikaya_cesky.pdf" \
			--top-level-division part --pdf-engine xelatex \
			${fn}*.docx $extra
	done

	s=Majjhima	
	fn=$(echo $s |tr '[:upper:]' '[:lower:]')
	pandoc --metadata-file="$res/pdf.yaml" \
		-M "title=$s nikaya česky" \
		-M "subtitle=$(date '+%Y-%m-%d %H:%m')" \
		--toc --toc-depth=4 \
		-o "${fn}_nikaya_cesky.pdf" \
		--top-level-division part --pdf-engine xelatex \
		'majjhima_nikaya česky 1 - 50 '[0-9]*.docx \
		'majjhima_nikaya česky 51 - 100 '[0-9]*.docx \
		'majjhima_nikaya česky 101 - 152 '[0-9]*.docx \
		$extra

	s=Khuddaka
	fn=$(echo $s |tr '[:upper:]' '[:lower:]')
	pandoc 	--metadata-file="$res/pdf.yaml" \
		-M "title=$s nikaya česky" \
		-M "subtitle=$(date '+%Y-%m-%d %H:%m')" \
		--toc --toc-depth=4 \
		-o "${fn}_nikaya_cesky.pdf" \
		--top-level-division part --pdf-engine xelatex \
		khuddakapatha.docx dhammapada.docx \
		udana[0-9]*.docx itivuttaka.docx \
		suttanipata-cesky[0-9]*.docx \
		theraghata-cesky[0-9]*.docx \
		petavatthu-cesky[0-9]*.docx \
		$extra
}


# check to see if this file is being run or sourced from another script

function _is_sourced()
{
        # https://unix.stackexchange.com/a/215279
        [ "${#FUNCNAME[@]}" -ge 2 ] \
        && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
	&& [ "${FUNCNAME[1]}" = 'source' ]
}

function gdocs_to_epub()
{
	pandoc --toc-depth=4 --metadata-file="$res/metadata.yaml"  -M "subtitle=$(date '+%Y-%m-%d %H:%m')" --epub-cover-image="$res/cover.jpg" --css="$res/book.css" -o tipitaka_cesky.epub \
	anguttara-nikaya-cesky[0-9]*.docx \
	digha-nikaya-cesky[0-9]*.docx \
	'majjhima_nikaya česky 1 - 50 '[0-9]*.docx \
	'majjhima_nikaya česky 51 - 100 '[0-9]*.docx \
	'majjhima_nikaya česky 101 - 152 '[0-9]*.docx \
	samyutta-nikaya-cesky[0-9]*.docx \
	khuddakapatha.docx dhammapada.docx \
	udana[0-9]*.docx itivuttaka.docx \
	suttanipata-cesky[0-9]*.docx \
	theraghata-cesky[0-9]*.docx \
	petavatthu-cesky[0-9]*.docx $extra

	pandoc --toc-depth=4 --metadata-file="$res/vinaya.yaml"  -M "subtitle=$(date '+%Y-%m-%d %H:%m')" \
		--css="$res/book.css" -o vinaya-pribehy.epub \
		vinaya_pitaka-pribehy[0-9]*.docx $extra
}



[ -z "$use_cache" ] && export use_cache=y
[ -z "$multilevel_toc" ] && export multilevel_toc=y

function _main()
{
	for targ in "$@"; do
		ext="${targ##*.}"
		[ -z "$source" ] && source="${targ%%.*}.html"

	case "$ext" in
		gen) gen_html ;;
		html) join_html && source="$targ" ;;
		epub) gen_epub ;;
		gdocs) gdocs_to_epub ;;
		pdf) gen_pdf ;;
		print) gen_print_pdf ;;
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

