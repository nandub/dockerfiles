#!/usr/bin/env bash

set -Eeuo pipefail

cp -a /build /tmp/
cd /tmp/build

if [ ! -f ./PKGBUILD ]; then
    printf 'PKGBUILD not found in /build.\n' >&2
    printf 'Mount the package directory itself, for example: docker run --rm -it -v "<package-dir>:/build" nandub/arch-pkgbuild\n' >&2
    exit 1
fi

# Install (from AUR) dependencies using aurutils. We avoid using makepkg
# -s since it is unable to install AUR dependencies.
if [ "${UPDATE_SYSTEM:-1}" = "1" ]; then
    sudo pacman -Syu --noconfirm
elif [ ! -e /var/lib/pacman/sync/core.db ]; then
    sudo pacman -Sy --noconfirm
fi

mapfile -t pkgbuild_deps < <(
    depends=()
    makedepends=()

    # shellcheck disable=SC1091
    source ./PKGBUILD

    if ((${#depends[@]})); then
        printf '%s\n' "${depends[@]}"
    fi

    if ((${#makedepends[@]})); then
        printf '%s\n' "${makedepends[@]}"
    fi
)

missing_deps=()
if ((${#pkgbuild_deps[@]})); then
    mapfile -t missing_deps < <(pacman --deptest "${pkgbuild_deps[@]}")
fi

if ((${#missing_deps[@]})) && [ "${INSTALL_AUR_DEPS:-1}" = "1" ]; then
    if ! command -v aur >/dev/null 2>&1; then
        printf 'AUR dependency installation requested, but aurutils is not installed.\n' >&2
        exit 1
    fi

    aur sync --noconfirm --noview "${missing_deps[@]}"
fi

# Do the actual building and install dependencies if needed.
makepkg -srif --noconfirm

if [ -n "${EXPORT_PKG:-}" ]; then
    shopt -s nullglob
    packages=( ./*.pkg.tar.* )

    if ((${#packages[@]})); then
        owner="$(stat -c '%u:%g' /build/PKGBUILD)"
        sudo chown "$owner" "${packages[@]}"
        sudo mv "${packages[@]}" /build
    fi
fi
