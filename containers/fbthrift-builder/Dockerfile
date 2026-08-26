FROM almalinux:10

# Minimal build dependencies for fbthrift
#
# groupinstall "Development Tools" + openssl and openssl-devel would also
# work, but we don't actually need all that.
#
# cmake is here because getdeps' cmake manifest lists it under [rpms]: with
# --allow-system-packages that lets getdeps use ours instead of bootstrapping
# CMake from source, which by itself took about ten minutes of every build.
RUN dnf install -y \
        automake \
        binutils \
        cmake \
        gcc-c++ \
        git \
        libaio-devel \
        m4 \
        openssl \
        openssl-devel \
        patch \
        perl-File-Compare \
        perl-File-Copy \
        python3

ARG files_cachebust=1
COPY files/ /
CMD ["/run.sh"]
