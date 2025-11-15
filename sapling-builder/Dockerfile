FROM almalinux:10

# Base system dependencies
RUN dnf groupinstall -y "Development Tools" && \
    dnf install -y clang-devel perl-FindBin perl-IPC-Cmd perl-Time-Piece \
        python3-devel python3-setuptools rpmdevtools

# EPEL dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf install -y yarnpkg

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && \
    sh /tmp/rustup.sh --profile minimal -y && \
    rm /tmp/rustup.sh
ENV PATH="${PATH}:/root/.cargo/bin"

ARG files_cachebust=1
COPY files/ /

# fbthrift dependency, unavailable as EPEL 10 package
RUN tar -C / --exclude=LICENSE -xJf /fbthrift.tar.xz
RUN rm -f /fbthrift.tar.xz

CMD ["/run.sh"]
