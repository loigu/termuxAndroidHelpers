#!/bin/bash

export TERMUX_HELPERS="$HOME/termuxAndroidHelpers"
[ -d "$TERMUX_HELPERS" ] || echo "WARNING: termux helpers not found" >&2

export PATH="${PATH}:~/bin:$TERMUX_HELPERS/bin:~/.shortcuts" # :$TERMUX_HELPERS/suttamerge"

export SSH_AUTH_SOCK="$HOME/.ssh_agent.sock"

function ssha-wrap()
{
	local prog="$1"
	shift
	. "$TERMUX_HELPERS/bin/ensure-ssh-agent.sh"
	"$prog" "$@"
}
export -f ssha-wrap

function git()
{
	[ "$1" = push -o "$1" = pull ] && ssha-wrap "$(which git)" "$@" || "$(which git)" "$@"
}
export -f git

function ssh() { ssha-wrap "$(which ssh)" "$@"; }; export -f ssh
function scp() { ssha-wrap "$(which scp)" "$@"; }; export -f scp
function rsync() { ssha-wrap "$(which rsync)" "$@"; }; export -f rsync

. ~/.texrc

function flip_coin()
{
	[ -n "$1" ] && local count="$1" || local count=1

	for f in $(seq 1 "$count"); do 
		[ $RANDOM -ge 16383 ] && i=1 || i=0
		echo $i
	done
}; export -f flip_coin

function rand()
{
	# defaúlt 0-100
	[ -n "$1" ] && p=$(( 32767 / "$1" )) || p=327
	echo $(( $RANDOM / "$p" ))
}
export -f rand

function frand()
{
	local r="-maxdepth 1"
	OPTIND=1
	while getopts "pr" arg "$@"; do
        case $arg in
        	p) export local pl=1 ;;
	        r) r="" ;;
		*) echo "unknown arg $arg (use -p -r)" >&2; print_help; return 1 ;;
        esac
	done
	shift $(($OPTIND - 1))

	local f="$1"
	[ -z "$f" ] && f="./"
	[ -d "$f" ] && t=$(mktemp) && find "$f" $r > "$t"  && f="$t"
	n=$(rand $(wc -l "$f"))
	res=$(head -n "$n" "$f" | tail -n 1)
	[ -f "$t" ] && rm "$t"

	echo "$res"
	[ -f "$res" -a "$pl" = 1 ] && termux-share "$res"
}
export -f frand
