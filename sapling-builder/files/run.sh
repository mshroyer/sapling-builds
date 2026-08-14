#!/bin/sh

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit="main"
fi

T_BLACKLIST=/blacklists/oss
CARGO_PACKAGE_BLACKLIST=/blacklists/cargo-packages
CARGO_TEST_BLACKLIST=/blacklists/cargo-tests

# Both suites run as saplingtest rather than root, because a fair number of
# their tests make something unwritable and then check that writing to it
# fails, which never happens as root.
require_blacklist() {
	if [ ! -f "$1" ]; then
		# Neither runner treats a missing blacklist as an error: run-tests.py
		# warns and carries on, and cargo would simply be passed no --exclude
		# arguments.  Either way we'd report every expected failure as a real
		# one, so check for ourselves.
		echo "Blacklist $1 is missing!" >&2
		exit 1
	fi
}

# Strip comments and blank lines from a blacklist.  Entries are package or test
# names, so callers can leave the result unquoted and let the shell split it.
blacklist_entries() {
	sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1"
}

# Run Sapling's .t suite against the tree we just built.
#
# The suite is written for the "hg" identity: legacy command aliases and some
# default templates only register when the running binary is named hg, per
# showlegacynames in eden/scm/sapling/registrar.py.  Upstream runs it the same
# way; see HGEXECUTABLEPATH in eden/scm/tests/targets.bzl.  `make oss` only
# produces sl, so link it.  A hardlink is needed rather than a symlink, since
# the identity comes from current_exe(), which resolves symlinks.
run_t_tests() {
	require_blacklist "$T_BLACKLIST"

	ln -f out/sl hg
	chown -R saplingtest tests

	su saplingtest -c "export PATH='$PATH'; cd '$(pwd)/tests' && \
		exec python3 run-tests.py \
		--with-hg='$(pwd)/hg' \
		--blacklist='$T_BLACKLIST' \
		--jobs='$(nproc)' \
		--timeout=300"
}

# Run the cargo tests for the same tree.
#
# Not every workspace member builds outside Meta, and cargo would otherwise
# stop at the first one that doesn't, so the ones that can't are excluded by
# name; see blacklists/cargo-packages for which and why.  --no-fail-fast so
# that one broken crate doesn't hide the rest.
#
# Upstream has its own runner, eden/scm/lib/run_cargo_tests.py, which invokes
# cargo once per crate instead.  It's deliberately forgiving--"linking with
# `cc` failed" and fbthrift codegen errors are both reported as passes--which
# makes it poor for gating a build, so we drive cargo ourselves.
run_cargo_tests() {
	require_blacklist "$CARGO_PACKAGE_BLACKLIST"
	require_blacklist "$CARGO_TEST_BLACKLIST"

	excludes=""
	for package in $(blacklist_entries "$CARGO_PACKAGE_BLACKLIST"); do
		excludes="$excludes --exclude $package"
	done

	skips=""
	for test in $(blacklist_entries "$CARGO_TEST_BLACKLIST"); do
		skips="$skips --skip $test"
	done

	# We're about to stop being root, and cargo needs to write to more than
	# just its cache: the target directory is out/cargo-target rather than
	# the usual target/, since build.py points .cargo/config.toml there, and
	# at least one build script--lib/python-modules--generates code straight
	# back into its own source directory.  Simplest to hand over the tree.
	chown -R saplingtest "$CARGO_HOME" .

	# su resets PATH, so pass ours along: cargo and thrift1 both live on it.
	su saplingtest -c "export PATH='$PATH'; cd '$(pwd)' && exec cargo test \
		--workspace --no-fail-fast $excludes -- $skips"
}

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

for patchscript in /patchscripts/*; do
	if [ -x "$patchscript" ]; then
		printf "\nApplying %s...\n" "$patchscript"
		"$patchscript"
	fi
done

GIT_HASH="$(git rev-parse --short=12 HEAD)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SAPLING_VERSION="0.2-${TIMESTAMP}_${GIT_HASH}"
export SAPLING_VERSION

cd eden/scm
make oss

/make_rpm.py --out /artifacts

# Build the RPM before testing, so a test failure still leaves us an artifact.
if [ -n "$SAPLING_RUN_TESTS" ]; then
	run_cargo_tests
	run_t_tests
fi
