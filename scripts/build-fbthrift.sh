#!/bin/sh

set -e

PROJECT=$(cd "$(dirname "$0")/.." && pwd)
cd "$PROJECT"

if [ -z "$DOCKER" ]; then
	DOCKER=podman
fi

"$DOCKER" build -t fbthrift-builder -f fbthrift-builder/Dockerfile
"$DOCKER" run -v ./artifacts:/artifacts fbthrift-builder
