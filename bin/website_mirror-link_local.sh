#!/bin/bash

[ -z "$1" ] && mirror_web help && exit 1
mirror_web.sh link_local "$@"

