#!/bin/sh

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit="main"
fi

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"

IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$IMAGE_ID" ./fbthrift-builder
"$DOCKER" run -v ./artifacts:/artifacts:z "$(cat "$IMAGE_ID")" /run.sh "$commit"
rm -f "$IMAGE_ID"
