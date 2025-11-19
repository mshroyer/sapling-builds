#!/bin/sh

set -e

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"


IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$IMAGE_ID" ./fbthrift-tester
"$DOCKER" run -v ./artifacts:/artifacts:z,ro --rm "$(cat "$IMAGE_ID")"
rm -f "$IMAGE_ID"
