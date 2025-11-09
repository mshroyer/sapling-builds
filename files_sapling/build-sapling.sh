#!/bin/sh

set -e

PATH="$PATH:$HOME/.cargo/bin:/opt/fbthrift/bin"
export PATH

cd /sapling
git pull

# Fix missing `anyhow` dependency
patch -p1 </patches/sapling000.patch

cd eden/scm

make oss
