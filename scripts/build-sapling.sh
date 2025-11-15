#!/bin/sh

# Build a fresh Sapling RPM for x86_64 AlmaLinux 10.
#
# Requires an existing build of fbthrift as a prerequisite.

set -e

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"


# Identify the latest fbthrift tarball in the artifacts directory.  This could
# be either one that was built locally using build-fbthrift.sh, or an artifact
# downloaded from GitHub with fetch-fbthrift.sh.
LATEST_FBTHRIFT="$(printf '%s\n' ./artifacts/x86_64/fbthrift-*.el10.x86_64.tar.xz | sort | tail -n1)"
if [ ! -f "$LATEST_FBTHRIFT" ]; then
	echo "No fbthrift build found in ./artifacts/ ! Run scripts/build-fbthrift.sh first" >&2
	exit 1
fi
echo "Using fbthrift from ${LATEST_FBTHRIFT}"
rm -f sapling-builder/files/fbthrift.tar.xz
ln "$LATEST_FBTHRIFT" sapling-builder/files/fbthrift.tar.xz

# Build and run the sapling-builder container.
IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$IMAGE_ID" ./sapling-builder
"$DOCKER" run -v ./artifacts:/artifacts:z "$(cat "$IMAGE_ID")"
rm -f "$IMAGE_ID"
