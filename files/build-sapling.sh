#!/bin/sh

set -e

PATH="$PATH:$HOME/.cargo/bin:/opt/fbthrift/bin"
export PATH

cd /sapling
git pull

cd eden/scm

make oss
