#!/bin/bash

if [[ -z "$2" ]]; then
	echo "Usage: $0 <display_name> <template>" >&2
	exit 1
fi

# Set the name
NAME="$(echo "$1" | tr '/' '_')"
TPL=$2

if [[ -d "private/$NAME.key" ]] || [[ -d "certs/$NAME.pem" ]]; then
	echo "Name already taken !" >&2
	exit 2
fi

openssl genrsa -out "private/$NAME.key" 2048
openssl req -new -key "private/$NAME.key" -out "req/$NAME.csr" -config openssl.cnf
openssl ca -create_serial -out "certs/$NAME.pem" -days 365 -extensions $TPL -config openssl.cnf -infiles "req/$NAME.csr"
