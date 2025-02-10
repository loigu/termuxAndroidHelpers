#!/bin/sh
[ "$1" = -v ] && termux-volume music "$2" && shift 2

termux-media-player play "$@"
