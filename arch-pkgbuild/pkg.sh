#!/usr/bin/env bash

cp -r /build /tmp/build
cd /tmp/build

# Install (from AUR) dependencies using aurutils. We avoid using makepkg
# -s since it is unable to install AUR dependencies.
sudo pacman -Sy
aur sync --noconfirm --noview \
    $(pacman --deptest $(source ./PKGBUILD && echo ${depends[@]} ${makedepends[@]}))

set -e

# Do the actual building and install dependencies if needed.
makepkg -sf --noconfirm 

if [ -n "$EXPORT_PKG" ]; then
    sudo chown $(stat -c '%u:%g' /build/PKGBUILD) ./*.pkg.tar.xz
    sudo mv ./*.pkg.tar.xz /build
fi
