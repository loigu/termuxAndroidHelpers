#!/bin/bash
words="~/Books/sutty/buddhaswords/ "
dppn="~/Books/sutty/www.palikanon.com/ "
friends="~/Books/sutty/suttafriends.org"
commy="~/Books/sutty/BuddhistTexts/"
searchable="~/Books/sutty/searchable/"
quotes="~/Books/quotes/"

base="words quotes"

help() {
	echo "$0 [-c "sources"] regex
	export sources='dppn friends commy searchable'
	export extra='-n --no-ignore-case'"
}
[ "$1" = -h ] && help && exit 0

[ "$1" = "-c" ] && base="$base $2" && shift 2

for x in $base; do
		sources="$sources $(eval echo \$$x)"
done

grep -irE --color=auto $extra "$@" $(eval echo $sources)

