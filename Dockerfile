FROM almalinux:10

# System dependencies
RUN dnf groupinstall -y "Standard" && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y python3-devel perl-FindBin perl-IPC-Cmd perl-Time-Piece \
        openssl-devel clang-devel rpmdevtools && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# EPEL-based dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf install -y yarnpkg && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# fbthrift dependency, unavailable as EPEL 10 package
ARG files_fbthrift_cachebust=1
COPY files_fbthrift/ /
ARG fbthrift_commit=main
RUN /build-fbthrift.sh ${fbthrift_commit}
ENV PATH="${PATH}:/opt/fbthrift/bin"

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && \
    sh /tmp/rustup.sh --profile minimal -y && \
    rm /tmp/rustup.sh
ENV PATH="${PATH}:${HOME}/.cargo/bin"

# Keep Sapling patches and scripts separate so we can modify them without
# losing the cached, time-consuming fbthrift build.
ARG files_sapling_cachebust=2
COPY files_sapling/ /

ENTRYPOINT ["/build-sapling.sh"]
