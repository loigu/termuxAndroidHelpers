#!/bin/bash

export TERMUX_HELPERS="$HOME/termuxAndroidHelpers"
[ -d "$TERMUX_HELPERS" ] || echo "WARNING: termux helpers not found" >&2

export PATH="${PATH}:$TERMUX_HELPERS/bin:$TERMUX_HELPERS/shortcuts"

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

function json_prettyprint()
{
	python -m json.tool "$@"
}
export -f json_prettyprint

