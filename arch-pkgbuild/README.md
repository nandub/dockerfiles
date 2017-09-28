# arch-pkgbuild

# Usage

```shell
  $ mkdir ./build
  $ cp PKGBUILD ./build
  $ docker run --rm -it -v$(pwd)/build:/build nandub/arch-pkgbuild
```

# How to build

```shell
  $ docker build -t nandub/arch-pkgbuild .
```
