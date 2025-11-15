#!/bin/sh

set -e

RPM="$(printf '%s\n' /artifacts/x86_64/sapling-*.el10.x86_64.rpm | sort | tail -n1)"
if [ ! -f "$RPM" ]; then
	echo "No sapling build found in artifacts/!" >&2
	exit 1
fi

echo "Checking sapling build: ${RPM}"

try_sl() {
	echo ""
	echo "Trying \`sl $@\`..."
	sl $@
	echo "Success!"
}

dnf install -y "$RPM"

try_sl --version
try_sl clone https://github.com/mshroyer/sapling-builds
cd sapling-builds
try_sl web
sleep 3
try_sl web --kill
