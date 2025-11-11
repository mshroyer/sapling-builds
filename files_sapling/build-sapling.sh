#!/bin/sh

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit=main
fi

cd /
git clone https://github.com/facebook/sapling.git
cd sapling
git checkout "$commit"

for patch in /patches/sapling*.patch; do
	patch -p1 <"$patch"
done

cd eden/scm
make oss

if [ ! -d /out ]; then
	mkdir /out
fi
/make_rpm.py --out /out
