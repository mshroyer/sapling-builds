FROM almalinux:10

# EPEL
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# System dependencies
RUN dnf groupinstall -y "Standard" && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y yarnpkg python3-devel perl-FindBin perl-IPC-Cmd perl-Time-Piece \
        openssl-devel clang-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o ~/rustup.sh && \
    sh ~/rustup.sh --profile minimal -y
ENV PATH="$PATH:$HOME/.cargo/bin"

ARG files_fbthrift_cachebust=1
COPY files_fbthrift/ /

# fbthrift dependency, unavailable as EPEL 10 package
ARG fbthrift_commit=main
RUN /build-fbthrift.sh ${fbthrift_commit}

# Cache initial clone of sapling repo
RUN git clone https://github.com/facebook/sapling.git

# Keep Sapling patches and scripts separate so we can modify them without
# losing the cached, time-consuming fbthrift build.
ARG files_sapling_cachebust=1
COPY files_sapling/ /
