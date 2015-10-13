#!/bin/bash

FORMATS="PEM|PKCS7"

if [[ -z "$3" ]]; then
	echo "Usage: $0 <cert> <$FORMATS> <out>" >&2
	exit 1
fi

if [[ ! -f "$1" ]]; then
	echo "Cert '$1' does not exist" >&2
	exit 2
fi
CERT="$1"

echo $FORMATS | tr '|' '\n' | fgrep -x $2 &> /dev/null
if [[ $? -ne 0 ]]; then
	echo "Format $2 not in $FORMATS"
	exit 3
fi
FORMAT=$2

OUT="$3"

if [[ $FORMAT == PKCS7 ]]; then
	
	CWD="$(pwd)"
	TMPDIR="$CWD/tmp"
	TMPFILE="$TMPDIR/chain.pem"

	mkdir "$TMPDIR" &> /dev/null

	cp "$CERT" "$TMPFILE"

	if [[ "$CERT" == "certs/ca.pem" ]]; then
		cd ..
	fi

	while ((1)) ; do
		cat certs/ca.pem >>  "$TMPFILE"
		[[ -f genRootCA.sh ]] && break
		cd ..
	done

	cd "$CWD"
	openssl crl2pkcs7 -certfile "$TMPFILE" -out "$OUT".p7b -nocrl
	rm -rf "$TMPDIR"
fi

if [[ $FORMAT == PEM ]]; then

	CWD="$(pwd)"
	TMPDIR="$CWD/tmp"
	TMPFILE="$TMPDIR/chain.pem"

	mkdir "$TMPDIR" &> /dev/null

	openssl x509 -in "$CERT" -issuer -subject > "$TMPFILE"

	if [[ "$CERT" == "certs/ca.pem" ]]; then
		cd ..
	fi

	while ((1)) ; do
		openssl x509 -in certs/ca.pem -issuer -subject >> "$TMPFILE"
		[[ -f genRootCA.sh ]] && break
		cd ..
	done

	cd "$CWD"
	mv "$TMPFILE" "$OUT".chain.pem
	rm -rf "$TMPDIR"
fi
