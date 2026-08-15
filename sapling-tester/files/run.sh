#!/bin/sh

set -e

RPM="$(printf '%s\n' /artifacts/sapling-*.el10.$(uname -m).rpm | sort | tail -n1)"
if [ ! -f "$RPM" ]; then
	echo "No sapling build found in artifacts/!" >&2
	exit 1
fi

echo "Checking sapling build: ${RPM}"

try_sl() {
	echo ""
	echo "Trying \`sl $@\`..."
	sl $@ >out.txt 2>&1

	if [ -n "$(grep -l old-version out.txt)" ]; then
		echo "error: sl is incorrectly outputting an old-version hint" >&2
		exit 1
	fi

	echo "Success!"
}

dnf install -y "$RPM"

try_sl --version
try_sl clone https://github.com/mshroyer/sapling-builds
cd sapling-builds
try_sl sl
try_sl web
