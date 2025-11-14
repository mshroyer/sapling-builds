#!/bin/sh

set -e

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"

BUILDER_IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$BUILDER_IMAGE_ID" -f sapling-builder/Dockerfile -v "$PWD/artifacts:/artifacts:ro,z" -t sapling-builder
"$DOCKER" run -v ./artifacts:/artifacts:z "$(cat "$BUILDER_IMAGE_ID")"
rm -f "$BUILDER_IMAGE_ID"
