#!/bin/bash

target="$1"
[ -z "$target" ] && target=/storage/71CF-01DA/backup/termux-sys.tar.bz

tar cvjf "$target" -C /data/data/com.termux/ .
sync

