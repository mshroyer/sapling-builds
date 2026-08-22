#!/bin/sh

set -e

TARBALL="$(printf '%s\n' /artifacts/fbthrift-*.$(uname -m).tar.xz | sort | tail -n1)"
if [ ! -f "$TARBALL" ]; then
	echo "No fbthrift build found in artifacts/!" >&2
	exit 1
fi

echo "Checking fbthrift build: ${TARBALL}"
tar -C / --exclude=LICENSE -xJf "$TARBALL"
/opt/fbthrift/bin/thrift1 --help >/dev/null

echo "Success!"
