FROM archlinux/base

ARG go_version

ENV GOROOT=/usr/local/go PATH=${PATH}:${GOROOT}/bin GOPATH=/go

RUN pacman -Syu --noconfirm wget tar \
    && wget --quiet https://dl.google.com/go/$go_version.linux-amd64.tar.gz -O go.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz \
    && pacman -Ru --noconfirm wget tar \
    && pacman -Scc --noconfirm
