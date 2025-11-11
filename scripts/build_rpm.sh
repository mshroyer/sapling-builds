#!/bin/sh

set -e

if [ -z "$DOCKER" ]; then
	DOCKER=podman
fi

if [ ! -d out ]; then
	mkdir out
fi

"$DOCKER" build . -t sapling-builder
"$DOCKER" run -v "$PWD/out:/out" sapling-builder
