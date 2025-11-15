#!/bin/sh

set -e

FILENAME="$(cat /artifacts/x86_64/fbthrift-buildstamp.el10.x86_64.txt)"
TARBALL="/artifacts/${FILENAME}"
echo "Checking fbthrift build: ${TARBALL}"
tar -C / --exclude=LICENSE -xJf "$TARBALL"
/opt/fbthrift/bin/thrift1 --help >/dev/null
