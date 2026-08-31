FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

# Base system dependencies
RUN apt update
RUN apt install -y bsdextrautils build-essential ca-certificates clang curl git \
    libaio1t64 libclang-dev libcurl4-openssl-dev locales nodejs perl pkg-config \
    python3 sudo xz-utils

# Sapling's build supports Python 3.12 at the newest (see its
# contrib/pick_python.py), but Ubuntu 26.04 only packages Python 3.14, under
# which the python-modules codegen crashes.  Install python3.12 from the
# deadsnakes PPA instead; pick_python.py will prefer it automatically.
RUN apt install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install -y python3.12-dev

# The counterpart of glibc-langpack-en on the RPM distros.
RUN locale-gen en_US.UTF-8

# Ubuntu 26.04's yarnpkg package is Yarn 4, which refuses the Yarn 1
# workflow Sapling's ISL build uses; the EPEL yarnpkg on the RPM builders is
# still classic Yarn 1.  Install classic Yarn from upstream instead.
RUN curl -fsSL https://github.com/yarnpkg/yarn/releases/download/v1.22.22/yarn-v1.22.22.tar.gz \
        | tar -xz -C /opt && \
    ln -s /opt/yarn-v1.22.22/bin/yarn /usr/local/bin/yarn

# Tells run.sh to package the build as a DEB instead of an RPM.
ENV PACKAGE_FORMAT=deb

ARG distro_tag=ub2604
ENV DISTRO_TAG="$distro_tag"

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
