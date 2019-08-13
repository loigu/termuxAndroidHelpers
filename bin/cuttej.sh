#!/bin/bash

base="$(pwd)"

pref=/data/data/com.termux/files/home/audiobooks/recordings/shwe-oo-min/

cd $pref

cut-from-mp3.sh ffmpeg/$1*.[mM][pP]3 $2 $3 quotes/20$1-tejaniya-$4.mp3

cd "$base"

