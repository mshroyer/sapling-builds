#!/bin/sh

# Build an fbthrift tarball for AlmaLinux 10.
#
# Builds from main or, if specified, a specific fbthrift commit.

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit="main"
fi

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"

FILES_CACHEBUST="$(latest_mtime_recursive ./fbthrift-builder/files)"
IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$IMAGE_ID" ./fbthrift-builder \
	  --build-arg=files_cachebust=$FILES_CACHEBUST
"$DOCKER" run -v ./artifacts:/artifacts:z --rm "$(cat "$IMAGE_ID")" /run.sh "$commit"
rm -f "$IMAGE_ID"
