#!/bin/bash
# shorthand script for SUT quotes

if [ -z "$1" ]; then
echo "[RECORDINGS_DIR=..../recordings/] $0 <fn in format 190707>[_0819_2] <from> <to> <label>"
	exit 0
fi

base="$(pwd)"

RECORDINGS_DIR="${RECORDINGS_DIR:-/data/data/com.termux/files/home/audiobooks/recordings/}"
pref="${RECORDINGS_DIR}/shwe-oo-min/"

cd $pref

cut-from-mp3.sh ffmpeg/$1*.[mM][pP]3 $2 $3 quotes/20$1-tejaniya-$4.mp3

cd "$base"

