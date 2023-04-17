#!/bin/bash

export TERMUX_HELPERS="$HOME/termuxAndroidHelpers"
[ -d "$TERMUX_HELPERS" ] || echo "WARNING: termux helpers not found" >&2

export PATH="${PATH}:$TERMUX_HELPERS/bin:$TERMUX_HELPERS/shortcuts"

function json_prettyprint()
{
	python -m json.tool "$@"
}
export -f json_prettyprint

