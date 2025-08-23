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
	echo "$0 [-all] [-searchable] [-c "sources"] regex
	export sources='words dppn friends commy searchable quotes'
	export extra='-n --no-ignore-case'"
}

update_mrpro()
{
	local p="$PWD"
	cd ~/books/quotes

	local last=$(find . -iname "20*.mrpro" -cnewer "mrpro-quotes.txt" |sort -r|head -n 1)
	[ ! -f "$last" ] || \
		mrpro-quotes.sh "$last" "mrpro-quotes.txt"
	local ret="$?"

	cd "$p"
	return $ret
}

update_fbreader()
{
	local p="$PWD"
	cd ~/books/quotes

	[ books.txt -nt books.db ] || \
		fbreader-quotesdb.sh books.db books.txt
	local ret=$?

	cd "$p"
	return $ret
}

[ "$1" = -h ] && help && exit 0

[ "$1" = '-searchable' ] && base="searchable" && shift

[ "$1" = '-all' ] && base="words quotes dppn commy searchable friends" && shift
[ "$1" = "-c" ] && base="$base $2" && shift 2


s=''
for x in $sources $base; do
	if [ "$x" = quotes ]; then
		update_mrpro
		update_fbreader
	fi

	s="$s $(eval echo \$$x)"
done

grep -irE --color=auto $extra "$@" $(eval echo $s)

