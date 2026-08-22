FROM ubuntu:26.04

RUN apt update
RUN apt install -y libaio1t64 xz-utils

# Ubuntu uses a .1t64 suffix for 64-bit .so libraries that use 64-bit time_t,
# even though this is already the default for 64-bit Linux.  We can get a
# binary linked against libaio.so.1 on AlmaLinux 10 to run here by just
# creating a symlink:
RUN ln -s /usr/lib/$(uname -m)-linux-gnu/libaio.so.1t64 \
    /usr/lib/$(uname -m)-linux-gnu/libaio.so.1

ARG files_cachebust=1
COPY files/ /
CMD ["/run.sh"]
