#!/bin/sh

set -e

TARBALL="$(ls -1 -t /artifacts/fbthrift-*.$(uname -m).tar.xz 2>/dev/null | head -n1)"
if [ ! -f "$TARBALL" ]; then
	echo "No fbthrift build found in artifacts/!" >&2
	exit 1
fi

echo "Checking fbthrift build: ${TARBALL}"
tar -C / --exclude=LICENSE -xJf "$TARBALL"
/opt/fbthrift/bin/thrift1 --help >/dev/null

echo "Success!"
