#!/bin/sh

set -e

tarball="$(printf '%s\n' /artifacts/fbthrift-*.tar.xz | sort | tail -n1)"
echo "Checking fbthrift build: ${tarball}"
tar -C / -xJf "$tarball"
/opt/fbthrift/bin/thrift1 --help >/dev/null
