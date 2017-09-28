# BUILD-USING:    docker build -t nandub/arch-pkgbuild .
# TEST-USING:     docker run --rm -i -t -h=arch-pkgbuild --name=arch-pkgbuild nandub/arch-pkgbuild /bin/bash
# RUN-USING:      docker run --rm -h=arch-pkgbuild --name=arch-pkgbuild nandub/arch-pkgbuild

#pkgbuild-introspection to test AUR files  on archlinux

#VERSION        0.0.1

FROM           archlinux/base
MAINTAINER     Fernando Ortiz <dev+docker@nandub.info>

# Update the repositories
RUN pacman -Syy

# Install pkgbuild-introspection fakeroot
RUN pacman -S --noconfirm binutils cmake fakeroot file gcc make pkgbuild-introspection sudo

VOLUME build

WORKDIR build

COPY pkg.sh /pkg.sh

RUN groupadd -r docker \
    && useradd -m docker -g docker -s /bin/bash \
    && echo '%docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

CMD ["/pkg.sh"]
