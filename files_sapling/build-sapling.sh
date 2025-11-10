#!/bin/sh

set -e

PATH="$PATH:$HOME/.cargo/bin:/opt/fbthrift/bin"
export PATH

commit="$1"
if [ -z "$commit" ]; then
	commit=main
fi

cd /
git clone https://github.com/facebook/sapling.git
cd sapling
git checkout "$commit"

# Fix missing `anyhow` dependency
patch -p1 </patches/sapling000.patch

cd eden/scm

make oss
