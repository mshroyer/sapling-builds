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
if [ ! -d fbthrift ]; then
	git clone https://github.com/facebook/fbthrift.git
fi
cd fbthrift

# In case we have an existing and already-patched clone.
git reset --hard HEAD

git checkout "$commit"
HASH="$(git rev-parse HEAD | head -c8)"
for patch in /patches/fbthrift*.patch; do
	patch -p1 <"$patch"
done

PREFIX="/opt/fbthrift"
FBCODE_BUILDER_ROOT="/tmp/fbcode_builder_getdeps-ZfbthriftZbuildZfbcode_builder-root"
INSTALLED="$FBCODE_BUILDER_ROOT/installed"
THRIFT1="$INSTALLED/fbthrift${PREFIX}/bin/thrift1"

if [ ! -f "$THRIFT1" ]; then
	./build/fbcode_builder/getdeps.py \
		--allow-system-packages build \
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
cp /fbthrift/LICENSE

FILENAME="fbthrift-$(date +%Y%m%d.%H%M%S).${HASH}.tar.xz"
tar -cJf "/artifacts/${FILENAME}" "$PREFIX"
echo "$FILENAME" >/artifacts/fbthrift-buildstamp.txt

# Don't cache the source in the docker image, saving about half a GB.
cd /
rm -rf /fbthrift

# I couldn't figure out how to change the output directory using getdeps, so
# just clean up caches from the tmp dir instead.
rm -rf "$FBCODE_BUILDER"
