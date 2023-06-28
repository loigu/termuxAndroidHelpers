#!/bin/bash
words="~/Books/sutty/buddhaswords/ "
dppn="~/Books/sutty/www.palikanon.com/ "
friends="~/Books/sutty/suttafriends.org"
commy="~/Books/sutty/BuddhistTexts/"
searchable="~/Books/sutty/searchable/"
quotes="~/Books/quotes/"

base="words quotes"
#todo pali

help() {
	echo "$0 [-a] [-c "sources"] regex
	export sources='dppn friends commy searchable'
	export extra='-n --no-ignore-case'"
}
[ "$1" = -h ] && help && exit 0

[ "$1" = -a ] && base="words quotes dppn commy searchable friends" && shift
[ "$1" = "-c" ] && base="$base $2" && shift 2

s=''
for x in $sources $base; do
		s="$s $(eval echo \$$x)"
done

grep -irE --color=auto $extra "$@" $(eval echo $s)

