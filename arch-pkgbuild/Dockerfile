# BUILD-USING:    docker build -t nandub/arch-pkgbuild .
# RUN-USING:      docker run --rm -it -v "$(pwd)/build:/build" nandub/arch-pkgbuild

#VERSION        0.0.2

ARG ARCH_IMAGE=archlinux:base
FROM ${ARCH_IMAGE}
LABEL maintainer="Fernando Ortiz <nandub+docker@nandub.info>"

# Install the Arch packaging baseline, AUR helper dependencies, and helper tools
# in one layer. Keep base-devel: PKGBUILD builds are expected to have it.
RUN pacman-key --init \
    && pacman -Syu --noconfirm --needed \
        archlinux-keyring \
        base-devel \
        git \
        jq \
        parallel \
        pacutils \
        sudo \
        wget \
    && groupadd -r docker \
    && useradd -m docker -g docker -s /bin/bash \
    && echo "docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker \
    && chmod 0440 /etc/sudoers.d/docker \
    && rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*

# Continue execution (and CMD) as docker:
USER docker
WORKDIR /home/docker

# Auto-fetch GPG keys (for checking signatures):
RUN mkdir -m 0700 .gnupg \
    && echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf

# Setup aurutils from its AUR package for AUR dependency support.
RUN git clone https://aur.archlinux.org/aurutils.git \
    && cd aurutils \
    && sudo pacman -Sy --noconfirm \
    && makepkg -si --noconfirm --needed \
    && cd .. \
    && rm -rf aurutils .cache .gnupg/S.* \
    && sudo rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*

USER root

COPY custom-repo.txt pkg.sh /home/docker/

RUN cat /home/docker/custom-repo.txt >> /etc/pacman.conf \
    && install -d -o docker -g docker /home/docker/custompkgs \
    && repo-add /home/docker/custompkgs/custom.db.tar.gz \
    && ln -sf custom.db.tar.gz /home/docker/custompkgs/custom.db \
    && ln -sf custom.files.tar.gz /home/docker/custompkgs/custom.files \
    && chmod 0755 /home/docker/pkg.sh \
    && chmod 0755 /home/docker \
    && chown -R docker:docker /home/docker

USER docker

# Build the package
WORKDIR /build
ENTRYPOINT ["/bin/bash"]
CMD ["/home/docker/pkg.sh"]
