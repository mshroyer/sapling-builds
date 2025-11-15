# Sapling Builds for Linux

Unofficial (and currently experimental) scripts and workflows for building [Sapling](https://sapling-scm.com), targeting
AlmaLinux 10 on x86\_64.

## Using

Pre-built RPMs are available as artifacts of successful [sapling workflow runs](https://github.com/mshroyer/sapling-builds/actions?query=workflow%3Asapling).

Running the build locally requires either docker or podman.  Clone the repo and run:

```sh
./scripts/build-fbthrift.sh
./scripts/test-fbthrift.sh

./scripts/build-sapling.sh
./scripts/test-sapling.sh
```

to build an fbthrift artifact and then Sapling itself.  Subsequent Sapling builds can skip rebuilding fbthrift, as long as you have a relatively recent working version.

## Details

There are official Sapling [releases](https://github.com/facebook/sapling/releases) for macOS, Windows, and Ubuntu—but not for AlmaLinux 10 or similar distributions.  Additionally, the official releases are updated infrequently: At the time of writing, the current release is about six months old.

Meta provides [instructions](https://sapling-scm.com/docs/introduction/installation) for building Sapling from source.  But these are not trivial to follow on AlmaLinux 10, requiring additional system dependencies, some patches, and a build of [fbthrift](https://github.com/facebook/fbthrift) as a prerequisite.  In turn, fbthrift itself needs similar finagling to build.

This repo provides a set of scripted docker/podman containers that build the fbthrift dependency and smoke test it within a fresh container, and then do the same with Sapling itself.  Those are run as two distinct steps so that the fbthrift build (very time-consuming and sometimes flaky) can be done once in order to support multiple builds of Sapling (not as slow, and fairly reliable).  For local builds, that means keeping an fbthrift tarball in your artifacts directory; for GitHub actions it means the sapling workflow downloads artifacts from the most recent successful fbthrift run.

## Caveats

- To my understanding, there isn't a working test suite for the public version of Sapling.  So the only testing this build does is of the "try installing the RPM and seeing if basic commands work" variety.  While Meta's main branch should generally work, it would still be possible for a bug to show up in a "successful" build here, which otherwise would have failed against the internal test suite.
- The fbthrift build is currently unreliable.  If building locally, you might instead want to fetch the latest successful build from my GitHub Actions by running `fetch-fbthrift.sh` instead of `build-fbthrift.sh`.
- Builds are non-hermetic and non-reproducible; even rebuilding artifacts at a specific commit hash may produce different results at different points in time.

## Troubleshooting

### SSL errors with Docker Desktop on macOS

If you're seeing errors from dnf like:

```
Error: Failed to download metadata for repo 'epel': Cannot prepare internal mirrorlist: Curl error (35): SSL connect error for https://mirrors.fedoraproject.org/metalink?repo=epel-z-10&arch=x86_64 [OpenSSL/3.2.2: error:06880006:asn1 encoding routines::EVP lib]
```

this is probably a [known Apple Rosetta emulation issue](https://github.com/containers/podman/issues/18301).  Try configuring Docker Desktop to use its beta Docker VMM emulation mode instead of Rosetta.

## FAQ

### Why not a source RPM?

Both Sapling's and fbthrift's builds are non-hermetic: They fetch yarn packages, additional sources from GitHub, and so on.
