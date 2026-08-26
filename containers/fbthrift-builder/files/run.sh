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

# Ensure we can actually write artifacts before going through a long build.
touch /artifacts/foo
rm -f /artifacts/foo

cd /
if [ ! -d fbthrift ]; then
	git clone https://github.com/facebook/fbthrift.git
fi
cd fbthrift

# In case we have an existing and already-patched clone.
git reset --hard HEAD

git checkout "$commit"
GIT_HASH="$(git rev-parse --short=8 HEAD)"
GIT_DATE="$(env TZ=UTC git log -1 --format=%cd --date=format-local:%Y%m%d)"
GIT_TIME="$(env TZ=UTC git log -1 --format=%cd --date=format-local:%H%M%S)"
for patch in /patches/fbthrift*.patch; do
	if [ -f "$patch" ]; then
		printf "\nApplying %s...\n" "$patch"
		patch -p1 <"$patch"
	fi
done

# Additional patches we've added to getdeps manifests.
for p in /patches/getdeps/*.patch; do
	if [ -f "$p" ]; then
		cp "$p" /fbthrift/build/fbcode_builder/patches/
	fi
done

PREFIX="/opt/fbthrift"
FBCODE_BUILDER_ROOT="/tmp/fbcode_builder_getdeps-ZfbthriftZbuildZfbcode_builder-root"
INSTALLED="$FBCODE_BUILDER_ROOT/installed"
THRIFT1="$INSTALLED/fbthrift${PREFIX}/bin/thrift1"

if [ ! -f "$THRIFT1" ]; then
	./build/fbcode_builder/getdeps.py \
		--allow-system-packages build \
		--extra-cmake-defines='{"enable_tests": "OFF"}' \
		--src-dir=. fbthrift \
		--project-install-prefix "fbthrift:$PREFIX"
fi

# Running getdeps.py fixup-dyn-deps produces a binary with a missing "version"
# symbol, so let's just copy and strip all the libraries ourselves.
mkdir -p "$PREFIX/bin"
cp "$THRIFT1" "$PREFIX/bin/"
mkdir -p "$PREFIX/lib"
find "$INSTALLED" -name '*.so' | xargs -I{} cp -a {} "$PREFIX/lib/"
find "$INSTALLED" -name '*.so.*' | xargs -I{} cp -a {} "$PREFIX/lib/"
find "$PREFIX" -type f | xargs -I{} strip {}

cp -ar "$INSTALLED/fbthrift${PREFIX}/include" "$PREFIX/include"
cp /fbthrift/LICENSE "$PREFIX/"

FILENAME="fbthrift-${GIT_DATE}_${GIT_TIME}+${GIT_HASH}.$(uname -m).tar.xz"
echo "Saving artifact ${FILENAME}..."
tar -cJf "/artifacts/${FILENAME}" "$PREFIX"
