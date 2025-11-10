#!/bin/sh

set -e

commit="$1"
if [ -z "$commit" ]; then
	echo "Usage: $0 <commit>" >&2
	exit 1
fi

cd /
git clone https://github.com/facebook/fbthrift.git
cd fbthrift
git checkout "$commit"

# Make getdeps recognize AlmaLinux as an RPM system
patch -p1 </patches/fbthrift000.patch

./build/fbcode_builder/getdeps.py --allow-system-packages build fbthrift

# Don't cache the source in the docker image, saving about half a GB.
cd /
rm -rf /fbthrift

# I couldn't figure out how to change the output directory using getdeps, so
# just clean up caches from the tmp dir instead.
rm -rf /tmp/fbcode_builder_getdeps-ZfbthriftZbuildZfbcode_builder-root/{build,downloads,extracted,repos}
