#!/bin/sh

set -e

PROJECT=$(cd "$(dirname "$0")/.." && pwd)
cd "$PROJECT"

if [ -z "$DOCKER" ]; then
	DOCKER=podman
fi

BUILDER_IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$BUILDER_IMAGE_ID" -f fbthrift-builder/Dockerfile
"$DOCKER" run -v ./artifacts:/artifacts "$(cat "$BUILDER_IMAGE_ID")"
rm -f "$BUILDER_IMAGE_ID"

TESTER_IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$TESTER_IMAGE_ID" -f fbthrift-tester/Dockerfile
"$DOCKER" run -v ./artifacts:/artifacts:ro "$(cat "$TESTER_IMAGE_ID")"
rm -f "$TESTER_IMAGE_ID"
