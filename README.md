# Sapling Builds

A Dockerfile for building [Sapling](https://sapling-scm.com) for AlmaLinux 10.

## FAQ

### Why?

Meta provides [instructions](https://sapling-scm.com/docs/introduction/installation) for installing Sapling from source.  But these aren't trivial on AlmaLinux 10, requiring some patches and a build of [fbthrift](https://github.com/facebook/fbthrift) as a prerequisite.

### Why not a source RPM?

Both Sapling's and fbthrift's builds are non-hermetic: They fetch yarn packages, additional sources from GitHub, and so on.
