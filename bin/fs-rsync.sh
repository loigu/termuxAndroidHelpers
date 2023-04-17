#!/bin/bash

fs='nanda@sbsmtc.duckdns.org:'

case "$1" in
 d) to="$3"; from="$fs$2";;
 u) from="$2"; to="$fs$3";;
 *) echo "$0 <d|u> srcpath destpath"; exit 1;;
esac

rsync -avPx -e 'ssh -p 2222' --size-only "$from" "$to"

