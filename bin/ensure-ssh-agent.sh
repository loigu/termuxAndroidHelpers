#!/bin/bash

[ -z "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK="$HOME/.ssh_agent.sock"

if ! [ -S "$SSH_AUTH_SOCK" ];then
	screen -dmS ssh-agent ssh-agent -D -a "$SSH_AUTH_SOCK"
	[ ! -S "$SSH_AUTH_SOCK" ] && sleep 1
	ssh-add
fi

echo $SSH_AUTH_SOCK  >&2

