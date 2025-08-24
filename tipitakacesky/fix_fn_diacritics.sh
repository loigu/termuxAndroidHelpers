#!/bin/bash

function gen_rename()
{
	from="$1"
	to="$2"
	pdfout="${to%.*}-pdf.${to##*.}"

	rm -f "$to" "$pdfout"

	find "$from" -iname '*.html' |while read f; do
		dn=$(dirname "$f")
		fn=$(basename "$f")
		sn="${fn%%_*}"
		ext="${fn##*.}"
		name="${fn%.*}"; name=${name##*_}
		title=$(grep '<title>' "$f" |sed -e 's/.*>\([^<]*\)<.*/\1/')

		echo "mv '$f' '${dn}/${sn}_${title}.${ext}'" >> "$to"
		echo "mv '${dn}/${name}.pdf' '${dn}/${sn}_${title}.pdf'" >> "$pdfout"
	done

	chmod +x "$to" "$pdfout"
}

gen_rename "$@"

