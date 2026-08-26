FROM almalinux:10

RUN dnf install -y \
        libaio

ARG files_cachebust=1
COPY files/ /
CMD ["/run.sh"]
