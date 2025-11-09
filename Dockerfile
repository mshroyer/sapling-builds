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
        openssl-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o ~/rustup.sh && \
    sh ~/rustup.sh --profile minimal -y
ENV PATH="$PATH:$HOME/.cargo/bin"

# fbthrift dependency, unavailable as EPEL 10 package
ARG FBTHRIFT_CACHEBUST=2
COPY --chmod=755 fbthrift.sh /fbthrift.sh
COPY fbthrift000.patch /fbthrift000.patch
RUN /fbthrift.sh

# Cache initial clone of sapling repo
RUN git clone https://github.com/facebook/sapling.git

ARG BUILD_CACHEBUST=3
COPY --chmod=755 build.sh /build.sh
