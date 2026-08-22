FROM fedora:44

ARG distro_tag=fc44
ENV DISTRO_TAG="$distro_tag"

ARG files_cachebust=1
COPY files/ /

CMD ["/run.sh"]
