#!/bin/sh

set -e

distro=el10
while getopts d: flag
do
	case "$flag" in
		d)
			distro="$OPTARG"
			;;

		*)
			echo "Unknown flag: $flag" >&2
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"


mirror_distro_files "./sapling-tester/$distro"

FILES_CACHEBUST="$(latest_mtime_recursive ./sapling-tester/files)"
IMAGE_ID="$(mktemp)"
"$DOCKER" build --iidfile="$IMAGE_ID" "./sapling-tester/$distro" \
	  --build-arg=files_cachebust=$FILES_CACHEBUST
"$DOCKER" run -v ./artifacts:/artifacts:z,ro --rm "$(cat "$IMAGE_ID")"
rm -f "$IMAGE_ID"
