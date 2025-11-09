#!/bin/sh

set -e

cd /
git clone https://github.com/facebook/fbthrift.git
cd fbthrift

# Make getdeps recognize AlmaLinux as an RPM system
patch -p1 </patches/fbthrift000.patch

./build/fbcode_builder/getdeps.py --allow-system-packages build fbthrift

# I couldn't figure out how to change the output directory using getdeps, so
# just clean up caches from the tmp dir instead.
rm -rf /tmp/fbcode_builder_getdeps-ZfbthriftZbuildZfbcode_builder-root/{build,downloads,extracted,repos}
