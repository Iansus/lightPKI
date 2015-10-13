#!/bin/bash

./initDirectory.sh

openssl req -new -newkey rsa:4096 -keyout private/ca.key -out req/ca.csr -config openssl.cnf -nodes
openssl ca -create_serial -out certs/ca.pem -days 3650 -keyfile private/ca.key -selfsign -extensions v3_ca -config openssl.cnf -infiles req/ca.csr
