#!/bin/bash

export TERMUX_HELPERS="$HOME/termuxAndroidHelpers"
[ -d "$TERMUX_HELPERS" ] || echo "WARNING: termux helpers not found" >&2

export PATH="${PATH}:~/bin:$TERMUX_HELPERS/bin:$TERMUX_HELPERS/shortcuts" # :$TERMUX_HELPERS/suttamerge"

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

function bp() { termux-battery-status |grep percentage|sed -e 's/[^0-9]*\([0-9]*\).*/\1/';}; export  -f bp;
function battery-wait()
{
	p=80
	[ -n "$1" ] && p="$1"
	# termux-wake-lock
	while sleep 60; do
		if [ "$(bp)" -ge "$p" ]; then
			termux-notification -c "battery > $p"
			termux-tts-speak 'battery charged'
			break
		fi
	done
	# termux-wake-unlock
} 
export -f battery-wait

