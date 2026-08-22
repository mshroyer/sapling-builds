[![sapling](https://github.com/mshroyer/sapling-builds/actions/workflows/sapling.yml/badge.svg)](https://github.com/mshroyer/sapling-builds/actions/workflows/sapling.yml)
[![fbthrift](https://github.com/mshroyer/sapling-builds/actions/workflows/fbthrift.yml/badge.svg)](https://github.com/mshroyer/sapling-builds/actions/workflows/fbthrift.yml)

# Sapling RPMs for Linux

Unofficial (and currently experimental) podman/docker containers and workflows for building [Sapling](https://sapling-scm.com) packages for AlmaLinux 10.  x86\_64 and aarch64 are supported.

## Building locally

Pre-built RPMs are available as artifacts of successful [sapling workflow runs](https://github.com/mshroyer/sapling-builds/actions?query=workflow%3Asapling).

Running the build locally requires either docker or podman.  Clone the repo and run:

```sh
./scripts/sapling-build.sh      # Build the RPM
./scripts/sapling-smoketest.sh  # Check that it installs and runs in a minimal container
```

Pass `-t` to additionally run Sapling's `.t` suite after building:

```sh
./scripts/sapling-build.sh -t
```

If any tests fail the script will exit with a nonzero status, but an RPM will still have been created.

The container's architecture determines which architecture Sapling is built for; the build script does not cross-compile.  If you're building on an aarch64 Mac and want to produce an x86\_64 package, and you're using docker, you can run the container in Rosetta with:

```
export DOCKER_DEFAULT_PLATFORM=linux/amd64
./scripts/sapling-build.sh
./scripts/sapling-smoketest.sh
```

## Details

There are official Sapling [tarballs](https://github.com/facebook/sapling/releases) built on manylinux, so as to target most x86\_64 or aarch64 Linux distros.  These are great to have, but:

1. They're released infrequently (currently ~quarterly).
2. For maximum compatibility they bundle their own copies of libpython, libcurl, and libssl instead of relying on system packages.
3. Because of the combination of 1 and 2, using these binary releases means running code that could be missing important security updates.

This repo is an attempt to get regular AlmaLinux builds of Sapling that dynamically link to those dependencies that are available as system libraries, packaged as RPMs for convenience.

## Special dependencies

### libssl

Upstream Sapling's http-client crate enables the `static-ssl` feature on its curl dependency, causing OpenSSL to be statically linked into the binary.  If built on a host with libcurl-devel, however, the system libcurl is dynamically linked, transitively pulling in an additional dynamic dependency on libssl anyway.  I'm not sure this actually causes any issues in practice, but it's not ideal.

My original approach was to go maximally statically-linked by building in a container without libcurl, which causes the curl crate to build and statically link its own copy of libcurl; this resulted in no system dependency on either libcurl or libssl.  But as mentioned above, I'd rather rely on system curl and OpenSSL so that security updates can be applied without rebuilding Sapling.  Currently we patch Sapling's http-client to not statically link libssl.  This yields a slightly smaller RPM at the cost of a larger dependency tree.

### fbthrift

Prior to [a commit in December 2025](https://github.com/facebook/sapling/commit/3255f860ffee22975e37278475955a8ba6f398c6), building Sapling required a prexisting thrift1 binary from [facebook/fbthrift](https://github.com/facebook/fbthrift/) to be available on the `$PATH`.  As of 2026-01-12 it seemed this dependency could be safely removed, possibly making the entire fbthrift workflow obsolete.

However, [a later commit in February 2026](https://github.com/facebook/sapling/commit/f54b2938510b3c27ec00ce9dc9451c0a7556e2d0) caused the build to fail once again if a pre-existing `thrift1` binary isn't available on the build host.  As of 2026-08-13 it's again building fine without `thrift1`, but for now I'll keep the fbthrift workflow running in case we end up needing it again.  In particular, it seems to be needed by at least one of the cargo tests, should I enable those.

## Caveats

Builds are non-hermetic and non-reproducible; even rebuilding artifacts at a specific commit hash may produce different results at different points in time.

The workflow runs most of Sapling's `.t` tests, but tests that depend on Meta-internal features are blacklisted, as are a few that are flaky.  Cargo and Python tests are not currently run.

## The churn

[This Google Sheet](https://docs.google.com/spreadsheets/d/1EQYsPPTVHO4tZdhJcjCAGfNV18xw_c9bFjFEdGXgiLs/edit?usp=sharing) tracks the effort involved in keeping fbthrift's and sapling's builds green, in light of churn in the upstream sources.

Neither of the builds seem to be flaky, but they do break occasionally.  Typical problems include missing C++ includes or Rust dependencies that need to be patched in, or old patches becoming obsolete as problems are eventually fixed upstream.  For a period, Sapling's build also depended on the Rust unstable `once_cell_try` feature, but this was eventually [fixed upstream](https://github.com/facebook/sapling/commit/9b2c2e21627ed58da5ebc15504e3b7adaa079a3e).

## Troubleshooting

### SSL errors with Docker Desktop on macOS

If you're cross-compiling to x86\_64 from aarch64 and seeing errors from dnf like:

```
Error: Failed to download metadata for repo 'epel': Cannot prepare internal mirrorlist: Curl error (35): SSL connect error for https://mirrors.fedoraproject.org/metalink?repo=epel-z-10&arch=x86_64 [OpenSSL/3.2.2: error:06880006:asn1 encoding routines::EVP lib]
```

this is probably a [known Apple Rosetta emulation issue](https://github.com/containers/podman/issues/18301).  Try configuring Docker Desktop to use its beta Docker VMM emulation mode instead of Rosetta.

## FAQ

### Why not a source RPM?

Both Sapling's and fbthrift's builds are non-hermetic: They fetch yarn packages, additional sources from GitHub, and so on.

## License

The Sapling builds themselves are [licensed by Meta under GPLv2](https://github.com/facebook/sapling/blob/main/LICENSE).

The scripts, Dockerfiles, other source contents of this repo are provided under the MIT license:

```
Copyright (c) 2025–2026 Mark Shroyer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
