FROM almalinux:10

# System dependencies
RUN dnf groupinstall -y "Development Tools" && \
    dnf install -y python3-devel perl-FindBin perl-IPC-Cmd perl-Time-Piece \
        openssl-devel clang-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# EPEL-based dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf install -y yarnpkg && \
    dnf clean all && \
    rm -rf /var/cache/dnf

ARG files_fbthrift_cachebust=1
COPY files_fbthrift/ /

# fbthrift dependency, unavailable as EPEL 10 package
ARG fbthrift_commit=main
RUN /build-fbthrift.sh ${fbthrift_commit}

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o ~/rustup.sh && \
    sh ~/rustup.sh --profile minimal -y

# Keep Sapling patches and scripts separate so we can modify them without
# losing the cached, time-consuming fbthrift build.
ARG files_sapling_cachebust=1
COPY files_sapling/ /
