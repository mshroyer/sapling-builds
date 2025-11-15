FROM almalinux:10

# System dependencies
RUN dnf groupinstall -y "Standard" && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y python3-devel perl-FindBin perl-IPC-Cmd perl-Time-Piece \
        openssl-devel clang-devel rpmdevtools && \
    dnf clean all

# EPEL-based dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release && \
    dnf install -y yarnpkg && \
    dnf clean all

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && \
    sh /tmp/rustup.sh --profile minimal -y && \
    rm /tmp/rustup.sh
ENV PATH="${PATH}:/root/.cargo/bin"

# fbthrift dependency, unavailable as EPEL 10 package
ARG files_cachebust=1
COPY files/ /
RUN tar -C / --exclude=LICENSE -xJf /fbthrift.tar.xz
RUN rm -f /fbthrift.tar.xz

CMD ["/run.sh"]
