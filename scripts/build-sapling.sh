#!/bin/sh

set -e

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"


LATEST_FBTHRIFT="$(printf '%s\n' ./artifacts/x86_64/fbthrift-*.el10.x86_64.tar.xz | sort | tail -n1)"
if [ ! -f "$LATEST_FBTHRIFT" ]; then
	echo "No fbthrift build found in ./artifacts/ ! Run scripts/build-fbthrift.sh first" >&2
	exit 1
fi

echo "Using fbthrift from ${LATEST_FBTHRIFT}"
ln "$LATEST_FBTHRIFT" sapling-builder/files/fbthrift.tar.xz

BUILDER_IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$BUILDER_IMAGE_ID" ./sapling-builder
"$DOCKER" run -v ./artifacts:/artifacts:z "$(cat "$BUILDER_IMAGE_ID")"
rm -f "$BUILDER_IMAGE_ID"
