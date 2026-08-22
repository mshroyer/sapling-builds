FROM almalinux:10

ARG distro_tag=el10
ENV DISTRO_TAG="$distro_tag"

ARG files_cachebust=1
COPY files/ /

CMD ["/run.sh"]
