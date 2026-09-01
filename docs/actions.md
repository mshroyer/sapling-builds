# GitHub Actions

## [release](./.github/workflows/release.yml)

This is manually invoked to create distro packages from the same Sapling commit as an [official Sapling release](https://github.com/facebook/sapling/releases/).  Identify the latest release's commit hash and run:

    gh workflow run -f commit=$hash release
    
After successfully building and running `.t` tests against Sapling on each target distribution, a release containing build artifacts will be left in a draft state.

## [sapling](./.github/workflows/sapling.yml)

Builds and optionally tests Sapilng for all supported distributions, on both x86\_64 and aarch64.  A specific Sapling commit can be targeted with the `commit` input, and setting the `test` input to true enables `.t` tests.

Reused by the release workflow.  It also runs on a schedule, without `.t` tests, to ensure we can still build the latest version of Sapling.

## [fbthrift](./.github/workflows/fbthrift.yml)

Builds a distro-agnostic fbthrift tarball for both x86\_64 and aarch64, which provides the `thrift1` binary.  This isn't currently needed to build Sapling, but it's required for at least one of the cargo tests.

Currently running on a schedule to make sure we can still get `thrift1` if needed.
