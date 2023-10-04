pkg install texlive-bin texlive-installer
termux-install-tl
tlmgr install texlive-scripts-extra
termux-patch-texlive
fmtutil-sys --byfmt pdflatex
texlinks
