#!/bin/sh

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit="main"
fi

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"

BUILDER_IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$BUILDER_IMAGE_ID" -f fbthrift-builder/Dockerfile
"$DOCKER" run -v ./artifacts:/artifacts:z "$(cat "$BUILDER_IMAGE_ID")" /run.sh "$commit"
rm -f "$BUILDER_IMAGE_ID"

TESTER_IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$TESTER_IMAGE_ID" -f fbthrift-tester/Dockerfile
"$DOCKER" run -v ./artifacts:/artifacts:z,ro "$(cat "$TESTER_IMAGE_ID")"
rm -f "$TESTER_IMAGE_ID"
