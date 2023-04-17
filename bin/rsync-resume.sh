#!/bin/bash
. "$TERMUX_HELPERS/bin/ensure-ssh-agent.sh"

rsync -avz -P --append-verify "$@"

