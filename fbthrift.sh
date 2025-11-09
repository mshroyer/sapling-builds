#!/bin/sh

set -e

git clone https://github.com/facebook/fbthrift.git
cd fbthrift
patch -p1 </fbthrift000.patch
./build/fbcode_builder/getdeps.py --allow-system-packages build fbthrift

#rm -rf /tmp/fbcode_builder_getdeps-ZfbthriftZbuildZfbcode_builder-root/{build,downloads,extracted,repos}
