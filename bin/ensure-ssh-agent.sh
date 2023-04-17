#!/bin/bash

[ -z "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK="$HOME/.ssh_agent.sock"

[ -z "$SSH_AGENT_PIDF" ] && export SSH_AGENT_PIDF="$HOME/.ssh_agent.pid"

kill -0 $(cat "$SSH_AGENT_PIDF") &>/dev/null || rm -f "$SSH_AUTH_SOCK"

if ! [ -S "$SSH_AUTH_SOCK" ];then
	screen -dmS ssh-agent bash -c 'echo $$ > "$SSH_AGENT_PIDF"; ssh-agent -D -a "$SSH_AUTH_SOCK"'
	[ ! -S "$SSH_AUTH_SOCK" ] && sleep 1
	ssh-add
fi

# echo $SSH_AUTH_SOCK  >&2

