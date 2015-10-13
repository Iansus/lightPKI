#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Usage: $0 <display_name>" >&2
	exit 1
fi

# Set the name
CA_NAME="$(echo "$1" | tr '/' '_')"

if [[ -d "$CA_NAME" ]]; then
	echo "Name already taken !" >&2
	exit 2
fi

mkdir "$CA_NAME"

# Directory init
cp initDirectory.sh openssl.cnf genCA.sh genCert.sh "$CA_NAME"
cd "$CA_NAME"
./initDirectory.sh
cd ..

openssl genrsa -out "$CA_NAME/private/ca.key" 2048
openssl req -new -key "$CA_NAME/private/ca.key" -out "req/$CA_NAME.csr" -config openssl.cnf
openssl ca -create_serial -out "certs/$CA_NAME.pem" -days 365 -extensions v3_ca -config openssl.cnf -infiles "req/$CA_NAME.csr"

cp "certs/$CA_NAME.pem" "$CA_NAME/certs/ca.pem"
