#!/bin/bash

export TERMUX_HELPERS="$HOME/termuxAndroidHelpers"
[ -d "$TERMUX_HELPERS" ] || echo "WARNING: termux helpers not found" >&2

export PATH="${PATH}:$TERMUX_HELPERS/bin:$TERMUX_HELPERS/shortcuts"

export SSH_AUTH_SOCK="$HOME/.ssh_agent.sock"

gitpath=$(which git)
function git()
{
	[ "$1" = push -o "$1" = pull ] && \
		. "$TERMUX_HELPERS/bin/ensure-ssh-agent.sh"
	"$gitpath" "$@"
}
export -f git

function json_prettyprint()
{
	python -m json.tool "$@"
}
export -f json_prettyprint

