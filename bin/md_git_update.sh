#!/bin/bash
cp -r ~/Documents/kahambana/macroDroid/conf/* ~/termuxAndroidHelpers/macrodroid/kuta-well/
tmp=$(mktemp)
find ~/termuxAndroidHelpers/macrodroid/kuta-well/ -type f |while read f; do json_prettyprint "$f" "${tmp}"||echo $f failed; mv "${tmp}" "$f"; done
