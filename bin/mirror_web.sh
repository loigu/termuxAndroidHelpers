#!/bin/bash
# -R mp3,pdf
# -r -l inf -nc -c
wget -m -pk --compression=auto "$@"

