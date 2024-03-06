pkg install texlive-bin texlive-installer
termux-install-tl
cp "$TERMUX_HELPERS"/conf/.texrc ~
echo '. ~/.texrc' >> ~/.bashrc
. ~/.texrc
tlmgr install texlive-scripts-extra
termux-patch-texlive
fmtutil-sys --byfmt pdflatex
texlinks
