FROM ubuntu:26.04

ARG distro_tag=ub2604
ENV DISTRO_TAG="$distro_tag"

# The Sapling DEB depends on libpython3.12, which Ubuntu 26.04 doesn't
# package; it comes from the deadsnakes PPA, which users of the DEB need
# enabled as well.
RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa

ARG files_cachebust=1
COPY files/ /

CMD ["/run.sh"]
