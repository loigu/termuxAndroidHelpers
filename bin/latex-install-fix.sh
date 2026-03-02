#!/bin/bash

if [ "$1" = "all" ]; then
	tlmgr install texlive-scripts-extra
	termux-patch-texlive
	texlinks
fi

fmtutil --sys --all

# rebuild  TeX Filename Database (FNDB) - might help when xelatex can't find for example soul.sty, while the package IS installed
texhash

