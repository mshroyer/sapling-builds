#!/bin/sh

set -e

commit="$1"
if [ -z "$commit" ]; then
	commit="main"
fi

BLACKLIST=/blacklists/oss

# Run Sapling's .t suite against the tree we just built.
#
# Two things about how it's invoked matter:
#
# The suite is written for the "hg" identity: legacy command aliases and some
# default templates only register when the running binary is named hg, per
# showlegacynames in eden/scm/sapling/registrar.py.  Upstream runs it the same
# way; see HGEXECUTABLEPATH in eden/scm/tests/targets.bzl.  `make oss` only
# produces sl, so link it.  A hardlink is needed rather than a symlink, since
# the identity comes from current_exe(), which resolves symlinks.
#
# And the tests run as an unprivileged user, because root ignores the
# permission bits that a number of them rely on.  `su -` matters too: it drops
# /root/.cargo/bin from PATH, which saplingtest can't read, and which would
# otherwise turn "command not found" into "permission denied".
run_tests() {
	if [ ! -f "$BLACKLIST" ]; then
		# run-tests.py only warns about a missing blacklist, and would go on
		# to report every expected failure as a real one.
		echo "Blacklist ${BLACKLIST} is missing!" >&2
		exit 1
	fi

	ln -f out/sl hg
	chown -R saplingtest tests

	su - saplingtest -c "cd '$(pwd)/tests' && exec python3 run-tests.py \
		--with-hg='$(pwd)/hg' \
		--blacklist='$BLACKLIST' \
		--jobs='$(nproc)' \
		--timeout=300"
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

PATH="$PATH:$HOME/.cargo/bin"
export PATH

GIT_HASH="$(git rev-parse --short=12 HEAD)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SAPLING_VERSION="0.2-${TIMESTAMP}_${GIT_HASH}"
export SAPLING_VERSION

cd eden/scm
make oss

/make_rpm.py --out /artifacts

# Build the RPM before testing, so a test failure still leaves us an artifact.
if [ -n "$SAPLING_RUN_TESTS" ]; then
	run_tests
fi
