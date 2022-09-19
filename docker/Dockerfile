FROM archlinux

ARG GO_VERSION

RUN pacman -Syu --noconfirm wget tar \
    && wget --quiet https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz -O go.tar.gz \
    && tar -C /usr/lib -xzf go.tar.gz \
    && rm go.tar.gz \
    && cd /usr/bin \
    && ln -s /usr/lib/go/bin/* . \
    && pacman -Ru --noconfirm wget tar \
    && pacman -Scc --noconfirm
