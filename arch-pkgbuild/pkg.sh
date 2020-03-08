#!/usr/bin/env bash

set -e

sudo chown -R root:docker /build

pushd /build
  makepkg -sf --noconfirm
popd
