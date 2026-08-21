#!/bin/sh

set -e

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"


FILES_CACHEBUST="$(latest_mtime_recursive ./sapling-tester/files)"
IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$IMAGE_ID" ./sapling-tester \
	  --build-arg=files_cachebust=$FILES_CACHEBUST
"$DOCKER" run -v ./artifacts:/artifacts:z,ro --rm "$(cat "$IMAGE_ID")"
rm -f "$IMAGE_ID"
