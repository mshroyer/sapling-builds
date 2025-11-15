# Sapling Builds for Linux

Unofficial (and currently experimental) scripts and workflows for building [Sapling](https://sapling-scm.com) for
AlmaLinux 10.

## Using

Pre-built RPMs are available as artifacts on successful [fbthrift workflow](https://github.com/mshroyer/sapling-builds/actions?query=workflow%3Asapling+is%3Asuccess) runs.

Running the build locally requires docker or podman.  Clone the repo and run:

```sh
./scripts/build-fbthrift.sh
./scripts/build-sapling.sh
```

to build an fbthrift artifact, then Sapling itself.  Subsequent Sapling builds can skip re-building fbthrift.

## Details

Meta provides [instructions](https://sapling-scm.com/docs/introduction/installation) for installing Sapling from source.  But these aren't trivial on AlmaLinux 10, requiring specific system dependencies, some patches, and a build of [fbthrift](https://github.com/facebook/fbthrift) as a prerequisite.  In turn, fbthrift itself requires some finagling to build.

This is a set of docker/podman containers to build and smoke-test the fbthrift dependency and then Sapling itself.  Those are done as two distinct steps so that the fbthrift build (very time-consuming and rather flaky) can be done once in order to support multiple Sapling builds (less slow and fairly reliable).

## Caveats

- As far as I know, it isn't possible to run Sapling's test suite on its public build.  This means the only testing this build does is of the "try installing the RPM and seeing if basic commands work" variety.  While Meta's main branch should generally work, it would still be possible for a bug to appear in a "successful" build here which would have failed against the internal test suite.
- The fbthrift build is unreliable.  If building locally, you might instead want to fetch the latest successful build from GitHub by running `fetch-fbthrift.sh` instead of `build-fbthrift.sh`.
- Builds are non-hermetic and non-reproducible; even rebuilding artifacts at a specific commit hash may produce different results at different points in time.
- Currently assumes an x86\_64 docker/podman host, and only supports x86\_64 builds.

## FAQ

### Why not a source RPM?

Both Sapling's and fbthrift's builds are non-hermetic: They fetch yarn packages, additional sources from GitHub, and so on.
