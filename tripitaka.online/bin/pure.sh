
function gen()
{
	while read f;do 
	if ! python json2html.py  "json/$f" pali  > "pure/${f%%.json}.html" 2>pure/r; then
		echo "$f" >>pure/failed
	else
		echo "$(cat pure/r);$f" >> pure/renaming
	fi
done <json.files
}

funczion rename_from_header()
{
find . -type f | while read f;do
	fn=$(basename "$f")
	dn=$(dirname "$f")
	nn=$(grep "<h.*${fn%%.*}" "$f" -m 1|sed -e 's/.*>\([^>]*\)<.*/\1/')

	expr match "$nn" "[0-9].*" &>/dev/null  &&  mv "$f" "$dn/$nn.html"
done

find . -iname '[^0-9]*.html' -type f | while read f;do 
	n=$(grep '<h.*>[0-9]' "$f" | sed -e 's/[^>*]*>\([0-9\.]*\).*/\1/')
	[ -z "$n" ] && continue
	dn=$(dirname "$f"); fn=$(basename "$f")
	mv "$f" "$dn/$n $fn"; done

}

function rename_from_list()
{

find pure/ -iname '[^0-9]*.html' -type f |sed -e 's/pure\/\(.*\).html/\1/' | while read d;do
	grep "$d" pure/renaming | while read line; do 
		t="${line%. *.json}"
		f=$(echo $line|cut -d ';' -f 2)
		d=$(dirname "$f")
		fn=$(basename "$f"); fn="${fn%%.json}"

		mv "pure/$d/${fn}.html" "pure/$d/${t}_${fn}.html"
	done
done
}

function rename_from_list2()
{
	find . -iname '[^0-9]*.html' -type f | while read d;do  line=$(grep "${d%%.html}" renaming -m 1); [ -z "$line" ] && echo "$d"  >>nf && continue; t="${line%%;*}"; dn=$(dirname "$d"); mv "${d}" "${dn}/${t}.html"; done
}

function prune()
{
	find . -type f -size -100c -exec rm {} \;
}
