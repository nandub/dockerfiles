# BUILD-USING:    docker build -t nandub/arch-pkgbuild .
# RUN-USING:      docker run --rm -it -v$(pwd)/build:/build nandub/arch-pkgbuild

#VERSION        0.0.1

FROM             archlinux:base-20231112.0.191179 
LABEL MAINTAINER='Fernando Ortiz <nandub+docker@nandub.info>'

# Generally, refreshing without sync'ing is discouraged, but we've a clean
# environment here.
RUN pacman-key --init \
    && pacman -Sy --noconfirm archlinux-keyring \
    && pacman -Sy --noconfirm --needed base-devel git

# Allow docker to run stuff as root (to install dependencies):
RUN groupadd -r docker \
    && useradd -m docker -g docker -s /bin/bash \
    && echo "docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker

COPY custom-repo.txt pkg.sh /home/docker/

RUN cat /home/docker/custom-repo.txt >> /etc/pacman.conf \
    && install -d /home/docker/custompkgs -o docker \
    && repo-add /home/docker/custompkgs/custom.db.tar.gz \
    && pacman -Sy --noconfirm --needed jq parallel wget pacutils \
    && pacman -Scc --noconfirm \
    && chown -R docker:docker /home/docker

# Continue execution (and CMD) as docker:
USER docker
WORKDIR /home/docker

# Auto-fetch GPG keys (for checking signatures):
RUN mkdir .gnupg && \
    touch .gnupg/gpg.conf && \
    echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf

# Setup aurutils for AUR package installation support
RUN git clone https://github.com/AladW/aurutils.git \
    && cd aurutils \
    && make build \
    && sudo make install \
    && cd .. && rm -rf aurutils

# Build the package
WORKDIR /build
ENTRYPOINT ["/bin/bash"]
CMD ["/home/docker/pkg.sh"]
