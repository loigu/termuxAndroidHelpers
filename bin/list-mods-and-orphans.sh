#!/bin/bash
# compare two directories, list modified & orphaned files 
# consider sqlite3, size compare for update speedup

function print_help()
{
	echo "[extra='-L' constraints='-not -path whatever']" $(basename "$0") "[-hfum] <indir1|infile1.md5> label1 <indir2|infile2.md5> label2 out-prefix" 
	echo -e "\th help \
		\n\tm md only \
		\n\tf force update existing md5s \
		\n\tu add&remove files into md5 file"
}

DEF_EXCLUDES="-not -iname .hidden -not -iname .dropbox -not -iname .inside -not -iname .outside -not -iname .nomedia -not -iname .directory -not -iname .emptyshow -not -ipath '*\.Moonreader*'"
# -not -iname position.sabp.dat"

#todo: separate md5 compare and apply actions
while getopts "hfum" arg; do
	case $arg in
	h) print_help; exit 0 ;;
	f) FORCE=1 ;;
	u) UPDATE=1 ;;
	m) MD_ONLY=1 ;;
	*) echo "unknown arg $arg" >&2; print_help; exit 1 ;;
	esac
done
shift $(($OPTIND - 1))

IN1="$1"
LABEL1="$2"
IN2="$3"
LABEL2="$4"
OUT="$5"
OLD_PWD=$(pwd)

[ -z "$IN1" ] && print_help && exit 1


[ -n "$OUT" ] && OUT=$(readlink -f "$OUT")-

#normalize & fullpath
IN1=$(readlink -f "$IN1")
IN2=$(readlink -f "$IN2")

make_list()
{
	local old=$(mktemp "$2.old.XXXXXX")
	if [ -f "$2" ]; then
		mv "$2" "$old"
	fi

	local pth=$(pwd)
	cd "$1" && find ${extra} . -type f $DEF_EXCLUDES ${constraints} | \
	while read f; do
		local m=''

		[ -f "$old" ] && m=$(grep -m 1 "\ ${f}\$" "$old")
		[ -z "$m" ] && m=$(md5sum "$f")
		echo "$m" >> "$2"
	done
	cd "$pth"

	sort -su -k 2 "$2" > "$old"
	mv "$old" "$2"
}


process_lists()
{
	rm -f "$OUT$LABEL2-mv" "$OUT$LABEL2-dup" "$OUT$LABEL2-changed" "$OUT$LABEL2-missing" "$OUT$LABEL1-dup"
	
	local last=''
	local lmd=''
	sort "$IN1" | while read md fl; do
		#duplicates in source dir /?mirror?/
		if [ "$lmd" = "$md" ]; then
			#exist in target too - skip
			grep -qF "$md $fl" "$IN2" && continue

			echo "cp '$last' '$fl' " >> "$OUT$LABEL1-dup" && continue
		fi
		last="$fl"
		lmd="$md"

		local count=0
		# detect move & duplicates on out
		grep "^${md}" "$IN2" | while read m f; do
			count=$(expr $count + 1)
			[ "$fl" != "$f" ] && echo "mv '$f' '$fl'" >> "$OUT$LABEL2-mv"
			[ $count -gt 1 ] && echo "rm '$f'" >> "$OUT$LABEL2-dup"
		done

		grep -q "^${md}" "$IN2"  && continue

		name=$(basename "${fl}")
		loc=$(grep -m 1 "/${name}$" "$IN2")
		if [ -z "${loc}" ]; then
			echo -e "${md}\t${fl}" >> "$OUT$LABEL2-missing"
		else
			echo -e "${LABEL1}\t${fl}\t${LABEL2}\t${loc#*\ }" >> "$OUT$LABEL2-changed"
		fi
	done 
}

#todo: +dry run / create batch
#apply choice for whole dir?
#add new (add duplicates)
#move (beware of duplicates)
#replace changed (ask first option)
#delete removed (ask first, cleanup empty dirs)

function update_md5()
{
	local in_dir="$1"
	local md_file="$2"
	[ "$FORCE" = 1 ] && rm -f "$md_file"
	[ -f "$md_file" -a -z "${UPDATE}" ] && return 0

	make_list "$in_dir" "$md_file"
}

[ -d "$IN1" ] && update_md5 "$IN1" "$IN1.md5" && IN1="$IN1.md5"
[ -d "$IN2" ] && update_md5 "$IN2" "$IN2.md5" && IN2="$IN2.md5"
[ -n "$MD_ONLY" ] && exit 0

process_lists

