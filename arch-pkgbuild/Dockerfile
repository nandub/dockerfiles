# BUILD-USING:    docker build -t nandub/arch-pkgbuild .
# RUN-USING:      docker run --rm -it -v$(pwd)/build:/build nandub/arch-pkgbuild

#VERSION        0.0.1

FROM           archlinux/base
MAINTAINER     Fernando Ortiz <nandub+docker@nandub.info>

# Update the repositories
RUN pacman-key --refresh-keys \
    && pacman -Sy --noconfirm sudo

# Install
RUN pacman -Sy --noconfirm awk binutils cmake curl fakeroot file gcc grep make \
              && rm -fr /var/lib/pacman/sync /var/cache/pacman/pkg /etc/pacman.d/gnupg

#RUN pacman -Sy --noconfirm adns bash autoconf automake binutils cmake curl fakeroot file git glib2 icu libtirpc libnsl gcc make m4 openssl pkg-config readline sudo \
#               && rm -fr /var/lib/pacman/sync /var/cache/pacman/pkg /etc/pacman.d/gnupg

WORKDIR /docker

RUN groupadd -r docker \
    && useradd -m docker -g docker -s /bin/bash \
    && echo '%docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && chown -R docker:docker /docker

COPY pkg.sh /docker/pkg.sh

USER docker

VOLUME build

ENTRYPOINT ["/bin/bash"]

CMD ["/docker/pkg.sh"]

