#!/bin/bash

SCRIPT_PATH=$(readlink -f "$BASH_SOURCE")
SCRIPT_PATH=$(dirname "$SCRIPT_PATH")

old-pwd="$PWD"
cd "$SCRIPT_PATH"

for d in tdc2 tdc1; do
	mkdir -p "${d}-backup"
	find "$d" -type f | while read f;do
		fn="${f##$d/}"
		dn=$(dirname "${fn}")
		[ -d "$d-backup/${dn}" ] || mkdir -p "${d}-backup/${dn}"
		[ -f "${d}-backup/${fn}" ] || ln "$f" "${d}-backup/${fn}"
	done
done

RCLONE="rclone --config $SCRIPT_PATH/grconf "

echo tdc2-clone|$RCLONE sync gdrive-rclone-quota:'TDC2 Meeting Recordings' tdc2/ -P

# https://drive.google.com/folderview?id=1JfB-fF7SIr0Jfa6zzbWrvHhu3Z8Ctw5Q
echo tdc2-clone | $RCLONE sync  gdrive-rclone-quota:'Edited recordings 6-AREAs' tdc1/ -P

#wlp mentoring
mkdir -p wlp-mentoring
youtube-dl -U

cd "wlp-mentoring"
youtube-dl -f '18/22' 'https://youtu.be/P7F3AQDFU7k?list=PLuM4Tx4GNYsbPpz0BDUHZx2_ucKn-zHhA'
cd "$SCRIPT_PATH"

