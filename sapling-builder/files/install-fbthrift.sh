#!/bin/sh

set -e

LATEST_FBTHRIFT="$(printf '%s\n' /artifacts/fbthrift-*.tar.xz | sort | tail -n1)"
if [ -z "$LATEST_FBTHRIFT" ]; then
	echo "No fbthrift build found in artifacts/! Run scripts/build-fbthrift.sh first" >&2
	exit 1
fi

echo "Installing fbthrift from ${LATEST_FBTHRIFT}"
tar -C / --exclude=LICENSE -xJf "$LATEST_FBTHRIFT"
