FROM almalinux:10

# Base system dependencies
RUN dnf groupinstall -y "Development Tools"
RUN dnf install -y clang-devel glibc-langpack-en libaio libcurl-devel perl-FindBin \
    perl-IPC-Cmd perl-Time-Piece python3-devel python3-setuptools rpmdevtools sudo

# EPEL dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf install -y yarnpkg

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
ENV PATH="${PATH}:${HOME}/.cargo/bin"

ARG files_cachebust=1
COPY files/ /

# # fbthrift dependency, unavailable as EPEL 10 package
# RUN tar -C / --exclude=LICENSE -xJf /fbthrift.tar.xz
# RUN rm -f /fbthrift.tar.xz
# ENV PATH="${PATH}:/opt/fbthrift/bin"
# ENV THRIFT_INCLUDE_PATH="/opt/fbthrift/include"

CMD ["/run.sh"]
