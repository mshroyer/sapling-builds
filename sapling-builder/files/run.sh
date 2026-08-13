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
	if [ -f "$patch" ]; then
		printf "\nApplying %s...\n" "$patch"
		patch -p1 <"$patch"
	fi
done

for patchscript in /patchescripts/*; do
	if [ -x "$patchscript" ]; then
		printf "\nApplying %s...\n" "$patchscript"
		"$patchscript"
	fi
done

PATH="$PATH:$HOME/.cargo/bin"
export PATH

GIT_HASH="$(git rev-parse --short=12 HEAD)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SAPLING_VERSION="0.2-${TIMESTAMP}_${GIT_HASH}"
export SAPLING_VERSION

SAPLING_DISABLE_OLD_VERSION_HINT=1
export SAPLING_DISABLE_OLD_VERSION_HINT

cd eden/scm
make oss

/make_rpm.py --out /artifacts
