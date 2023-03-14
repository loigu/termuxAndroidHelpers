#!/bin/bash

if [ ! -f "$1.pem" -o -z "$2" -o "$1" = "-h" ]; then
	echo "usage: $0 oldprefix newprefix"
	echo "example - $0 jirizouhar2020 jirizoubar2023"
	exit 
f

past="$1"
new="$2"

#gen key
openssl genrsa -out tempkey 4096
openssl pkcs8 -topk8 -in tempkey -out "$new.key"
openssl rsa -pubout -in "tempkey" > "$new.pub"
rm tempkey

#gen request based on old cert
openssl x509 -x509toreq -in "$past.pem" -out "$new.req" -key "$new.key"

echo "req md5:"
openssl req -noout -modulus -in "$new".req |openssl md5
echo "key md5:"
openssl rsa -noout -modulus -in "$new".key |openssl md5

echo "key check:"
openssl rsa -in "$new.key" -check
echo "req check:"
openssl req -text -noout -verify -in "$new".req 

# clear gen - fields from scratch
# openssl req -out CSR.csr -new -key jirizouhar2023.key 

