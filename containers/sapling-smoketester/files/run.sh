#!/bin/sh

set -e

PKG="$(ls -1 -t /artifacts/sapling-*.${DISTRO_TAG}.$(uname -m).rpm \
	/artifacts/sapling-*.${DISTRO_TAG}.$(uname -m).deb 2>/dev/null | head -n1)"
if [ ! -f "$PKG" ]; then
	echo "No sapling build found in artifacts/!" >&2
	exit 1
fi

echo "Checking sapling build: ${PKG}"

try_sl() {
	echo ""
	echo "Trying \`sl $@\`..."
	sl "$@" 2>&1 | tee out.txt

	if [ -n "$(grep -l old-version out.txt)" ]; then
		echo "error: sl is incorrectly outputting an old-version hint" >&2
		exit 1
	fi

	echo "Success!"
}

case "$PKG" in
	*.deb)
		apt update
		apt install -y "$PKG"
		;;

	*)
		dnf install -y "$PKG"
		;;
esac

try_sl --version
try_sl debugpython -c 'print("Hello, world!  Python works...")'
try_sl clone https://github.com/mshroyer/sapling-builds
cd sapling-builds
try_sl sl
try_sl web
