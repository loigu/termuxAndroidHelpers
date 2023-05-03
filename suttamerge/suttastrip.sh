#!/bin/bash

splittag="body"
[ -n "$3" ] && splittag="$3"
# remove head/tail
# <body> .. </body>
pl=$(grep "<$splittag" "$1"  -n  | cut -d : -f 1)
pl=$(( $pl + 1))                     .../tinna_menio/pdf $ 

ll=$(grep "</$splittag" "$1"  -n  | cut -d : -f 1)
ll=$(( $ll - 1))

bn=$(basename "$1")
echo "<div id=\"${bn&&.*}\">" > "$2"
head -n $ll "$1" | tail -n +$pl >> "$2"
echo '</div>' >> "$2"

