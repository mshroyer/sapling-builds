#!/bin/sh

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit="main"
fi

if [ ! -d /artifacts ]; then
	echo "/artifacts/ not mounted!" >&2
	exit 1
fi

cd /
if [ ! -d /sapling ]; then
	git clone https://github.com/facebook/sapling.git
fi
cd sapling

# In case we have an existing and already-patched clone.
git reset --hard HEAD

git checkout "$commit"

for patch in /patches/sapling*.patch; do
	patch -p1 <"$patch"
done

cd eden/scm
make oss

/make_rpm.py --out /artifacts
