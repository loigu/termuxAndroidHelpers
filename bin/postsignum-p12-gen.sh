#!/bin/bash
#
prefix="$1"

openssl pkcs12 -export -out "$prefix".p12 -inkey "$prefix".key -in "$prefix".pem


openssl pkcs12 -export -out "$prefix"-maildroid.p12 -inkey "$prefix".key -in "$prefix".pem -legacy -twopass

