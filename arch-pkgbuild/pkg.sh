#!/usr/bin/env bash

# Make a copy so we never alter the original
cp -r /build /tmp/build
cd /tmp/build

# Install (official repo + AUR) dependencies using yay. We avoid using makepkg
# -s since it is unable to install AUR dependencies.
aur sync --noconfirm --noview \
    $(pacman --deptest $(source ./PKGBUILD && echo ${depends[@]} ${makedepends[@]}))

set -e

# Do the actual building
makepkg -sf --noconfirm 

# Store the built package(s). Ensure permissions match the original PKGBUILD.
if [ -n "$EXPORT_PKG" ]; then
    sudo chown $(stat -c '%u:%g' /build/PKGBUILD) ./*.pkg.tar.xz
    sudo mv ./*.pkg.tar.xz /build
fi

#sudo chown -R root:docker /build
#pushd /build
#  sudo pacman -Sy
#  if [ -f aur.deps ]; then
#    deps=$(cat aur.deps)
#    aur sync --noconfirm --noview $deps
#  fi
#  makepkg -sf --noconfirm
#popd
