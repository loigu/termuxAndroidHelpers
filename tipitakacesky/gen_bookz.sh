#!/bin/bash
#

script_dir=$(dirname "${BASH_SOURCE}")
res="$script_dir/res"

# check to see if this file is being run or sourced from another script

function _is_sourced()
{
        # https://unix.stackexchange.com/a/215279
        [ "${#FUNCNAME[@]}" -ge 2 ] \
        && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
	&& [ "${FUNCNAME[1]}" = 'source' ]
}

function gen_print_pdf()
{
	for s in Anguttara Digha Samyutta; do
		fn=$(echo $s |tr '[:upper:]' '[:lower:]')
		pandoc --metadata-file="$res/pdf.yaml" \
			-M "title=$s nikaya česky" \
			-M "subtitle=$now" \
			--toc --toc-depth=4 \
			-o "${fn}_nikaya_cesky.pdf" \
			--top-level-division part --pdf-engine xelatex \
			${fn}*.docx $extra
	done

	s=Majjhima	
	fn=$(echo $s |tr '[:upper:]' '[:lower:]')
	pandoc --metadata-file="$res/pdf.yaml" \
		-M "title=$s nikaya česky" \
		-M "subtitle=$now" \
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
		-M "subtitle=$now" \
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

function gen_tipitaka()
{

	for t in $type; do
	case "$t" in
		epub) pandoc --toc-depth=4 --metadata-file="$res/metadata.yaml" \
		-M "subtitle=$now" --epub-cover-image="$res/cover.jpg" --css="$res/book.css" \
		-o tipitaka_cesky.epub \
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
		;;

		pdf) pandoc --toc --toc-depth=4 --metadata-file="$res/pdf.yaml" \
		--top-level-division part --pdf-engine xelatex \
		-M "subtitle=$now" \
		-o "tipitaka_cesky.pdf" \
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
		;;
	esac
	done
}

function gen_vinaya()
{
	for t in $type; do
	case "$t" in
		epub) pandoc --toc-depth=4 --metadata-file="$res/vinaya.yaml"  -M "subtitle=$now" \
		--css="$res/book.css" -o vinaya-pribehy.epub \
		vinaya_pitaka-pribehy[0-9]*.docx $extra
		;;
		
		pdf) pandoc --toc --toc-depth=4 --top-level-division part --pdf-engine xelatex \
		--metadata-file="$res/vinaya.yaml"  -M "subtitle=$now" \
		--css="$res/book.css" -o vinaya-pribehy.pdf \
		vinaya_pitaka-pribehy[0-9]*.docx $extra
		;;
	esac
	done
}

function print_help()
{
	echo "type='$type' $0 [tipitaka|vinaya]"
}

[ -z "$type" ] && type="pdf epub"
now=$(date '+%Y-%m-%d %H:%M')

function _main()
{
	for targ in "$@"; do
	case "$targ" in
		vinaya) gen_vinaya ;;
		print) gen_print_pdf ;;
		tipitaka) gen_tipitaka ;;
		*|-h) print_help; exit 1 ;;
	esac
	done
}

if ! _is_sourced; then
	_main "$@"
fi

# arr=()
# while read f;do  arr+=( "$f" ); done<list
# pandoc "${arr[@]}" -o all.docx

