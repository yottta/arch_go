FROM archlinux/base

ARG go_version

RUN pacman -Syu --noconfirm wget tar

RUN wget --quiet https://dl.google.com/go/$go_version.linux-amd64.tar.gz -O go.tar.gz
RUN tar -C /usr/local -xzf go.tar.gz
RUN rm go.tar.gz

ENV PATH=${PATH}:/usr/local/go/bin
