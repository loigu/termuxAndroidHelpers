#!/bin/bash

if [ "$1" = "all" ]; then
	tlmgr install texlive-scripts-extra
	termux-patch-texlive
	texlinks
fi

fmtutil --sys --all
texhash
