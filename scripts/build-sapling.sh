#!/bin/sh

# Build a fresh Sapling RPM for x86_64 AlmaLinux 10.
#
# Builds from main in https://github.com/facebook/sapling, or from a specific
# commmit if one as given as an optional argument.  Requires an existing build
# of fbthrift in ./artifacts as a prerequisite.

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit="main"
fi

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"


# Build and run the sapling-builder container.
IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$IMAGE_ID" ./sapling-builder
"$DOCKER" run -v ./artifacts:/artifacts:z --rm "$(cat "$IMAGE_ID")" /run.sh "$commit"
rm -f "$IMAGE_ID"
