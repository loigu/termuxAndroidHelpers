#!/bin/bash

export TERMUX_HELPERS="$HOME/termuxAndroidHelpers"
[ -d "$TERMUX_HELPERS" ] || echo "WARNING: termux helpers not found" >&2

export PATH="${PATH}:$TERMUX_HELPERS/bin:$TERMUX_HELPERS/shortcuts"

export SSH_AUTH_SOCK="$HOME/.ssh_agent.sock"

function json_prettyprint()
{
	python -m json.tool "$@"
}
export -f json_prettyprint

