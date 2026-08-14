FROM almalinux:10

# Base system dependencies
RUN dnf groupinstall -y "Development Tools" && \
    dnf install -y clang-devel glibc-langpack-en libaio libcurl-devel perl-FindBin \
        perl-IPC-Cmd perl-Time-Piece python3-devel python3-setuptools rpmdevtools

# EPEL dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf install -y yarnpkg

# Rust
#
# Installed under /usr/local rather than /root so that the unprivileged user
# below can run cargo too.  As a side benefit it keeps /root off $PATH, which
# otherwise leaves an unreadable directory there for anyone but root: a PATH
# lookup that should fail with ENOENT fails with EACCES instead, which is
# enough to break test-extutil.py.
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH="${PATH}:/usr/local/cargo/bin"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && \
    sh /tmp/rustup.sh --profile minimal -y --no-modify-path && \
    rm /tmp/rustup.sh && \
    chmod -R a+rX "$RUSTUP_HOME" "$CARGO_HOME"

# Unprivileged user for the test suites.  Several tests make a file or
# directory unwritable and then check that writing to it fails, which never
# happens as root.
RUN useradd --create-home saplingtest

ARG files_cachebust=1
COPY files/ /

# fbthrift dependency, unavailable as EPEL 10 package.
#
# The sl binary itself builds without this again as of 2026-08-13, but the
# thrift crates in the cargo workspace still don't: their build scripts shell
# out to thrift1 to generate code, and fail outright when it isn't on $PATH.
# So it's needed for `build-sapling.sh --test`, and harmless otherwise.
RUN tar -C / --exclude=LICENSE -xJf /fbthrift.tar.xz
RUN rm -f /fbthrift.tar.xz
ENV PATH="${PATH}:/opt/fbthrift/bin"
ENV THRIFT_INCLUDE_PATH="/opt/fbthrift/include"

CMD ["/run.sh"]
