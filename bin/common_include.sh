#!/bin/bash

function media_type()
{
	file --mime-type -F ';'  "$1" | cut -d ";" -f 2 | cut -d '/' -f 1 | tr -d ' '
}
export -f media_type
