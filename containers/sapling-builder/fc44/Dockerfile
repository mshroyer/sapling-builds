FROM fedora:44

# Base system dependencies
RUN dnf group install -y development-tools
RUN dnf install -y clang-devel glibc-langpack-en libaio libcurl-devel perl-File-Copy \
    perl-FindBin perl-IPC-Cmd perl-Time-Piece python3.12-devel rpmdevtools yarnpkg

# We run the build as an unprivileged user, as running as root causes some .t
# tests to fail and also breaks rpmbuild on Fedora.  But we grant this user
# NOPASSWD sudo privileges so that it can copy the build artifacts into the
# output volume without messing with UID mapping.
RUN useradd --create-home build
RUN echo 'build ALL=(ALL) NOPASSWD: ALL' >>/etc/sudoers
USER build

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && \
    sh /tmp/rustup.sh --profile minimal -y && \
    rm /tmp/rustup.sh
ENV PATH="${PATH}:/home/build/.cargo/bin"

ARG files_cachebust=1
COPY files/ /

CMD ["/run.sh"]
