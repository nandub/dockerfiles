# BUILD-USING:    docker build -t nandub/arch-pkgbuild .
# TEST-USING:     docker run --rm -i -t -h=arch-pkgbuild --name=arch-pkgbuild nandub/arch-pkgbuild /bin/bash
# RUN-USING:      docker run --rm -h=arch-pkgbuild --name=arch-pkgbuild nandub/arch-pkgbuild

#pkgbuild-introspection to test AUR files  on archlinux

#VERSION        0.0.1

FROM           nandub/arch-sudo
MAINTAINER     Fernando Ortiz <dev+docker@nandub.info>

USER docker

# Update the repositories
RUN sudo pacman -Syy

# Install pkgbuild-introspection fakeroot
RUN sudo pacman -S --noconfirm pkgbuild-introspection fakeroot

# Add package to be built
ADD . /build/

RUN sudo chown -R docker:docker /build/

WORKDIR /build/

# Allow this file to be included into other Dockerfiles for testing
ONBUILD ADD . /build/

CMD ["mkaurball"]
