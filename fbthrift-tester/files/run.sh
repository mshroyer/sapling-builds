#!/bin/sh

set -e

FILENAME="$(cat /artifacts/fbthrift-buildstamp.txt)"
TARBALL="/artifacts/${FILENAME}"
echo "Checking fbthrift build: ${TARBALL}"
tar -C / -xJf "$TARBALL"
/opt/fbthrift/bin/thrift1 --help >/dev/null
