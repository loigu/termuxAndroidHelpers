#! /bin/bash

script=$(readlink -f "$BASH_SOURCE")
script_dir=$(dirname "$script")

if [ "$1" = "-f" ]; then
  force=1
  shift
fi

[ "$1" = down ] && down=1 && shift

[ ! -f menu.json -o "$force" = 1 ] && wget https://tripitaka.online/sutta/live/menu -O menu.json

[ ! -f sutta.list -o "$force" = 1 ] && python "$script_dir"/list.py menu.json > sutta.list

while read num path; do
  d=$(dirname "$path")
  fn=$(basename "$path")
  
  for sd in json si si-pi; do
    [ -d "$sd/$d" ] || mkdir -p "$sd/$d"
  done
  
  [ ! -f "json/$path".json  -o "$force" = 1 ] && wget -c "https://tripitaka.online/sutta/live/sutta/$num" -O "json/$path".json
  
  [ "$down" = 1 ] && continue

  [ -f "si/$d/$name.html" -a "$force" != "1" ] && continue

  python "$script_dir"/json2html.py "json/$path".json pali > "si-pi/$fn" 2>res
  [ "$?" != "0" ] && echo "$num $path" >> failed && continue

  name="$(cat res|cut -d ' ' -f 1)_$fn - $(cat res|cut -d ' ' -f 2-)"
  mv "si-pi/$fn" "si-pi/$d/$name.html"
  python "$script_dir"/json2html.py "json/$path".json > "si/$d/$name.html"
  [ ! -f "si/$d/$name.html" ] && echo "$num $path" >> failed
done < sutta.list

