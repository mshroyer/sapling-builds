#!/bin/sh

set -e

PATH="$PATH:$HOME/.cargo/bin:/tmp/fbcode_builder_getdeps-ZfbthriftZbuildZfbcode_builder-root/installed/fbthrift/bin"
export PATH

cd sapling
git pull

cd eden/scm

make oss
