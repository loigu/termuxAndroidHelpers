#!/bin/bash
base="~/Books/sutty/buddhaswords/  ~/Books/sutty/www.palikanon.com/ ~/Books/sutty/suttafriends.org"
commy="~/Books/sutty/BuddhistTexts/"
searchable="~/Books/sutty/searchable/"
quotes="~/Books/quotes/"

if [ "$1" = "-c" ]; then
	base="$base $commy"
	shift 1
fi

grep -irE $extra --color=always "$@" $(eval echo $base $quotes $searchable)

