#!/bin/bash

export PATH="${PATH}:~/bin:~/.shortcuts"
function json_prettyprint()
{
	python -m json.tool "$@"
}
export -f json_prettyprint

