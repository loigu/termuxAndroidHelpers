#!/bin/bash
#
prefix="$1"
openssl pkcs12 -export -out "${prefix}".p12 -inkey "${prefix}".key -in "${prefix}".pem -certfile postsignum_qca4_root.pem -certfile postsignum_qca4_sub.pem

#or
openssl pkcs12 -export -out "${prefix}".p12 -inkey "${prefix}".key -in "${prefix}".pem
