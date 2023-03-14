#!/bin/bash

export PATH="${PATH}:~/bin:~/.shortcuts"
function json_prettyprint()
{
	python -m json.tool "$@"
}
export -f json_prettyprint

function rsync-resume()
{
	rsync -avz -P --append-verify "$@"
}
export -f rsync-resume
