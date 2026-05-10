# arch-pkgbuild

# Usage

```shell
  $ cd path/to/package
  $ docker run --rm -it -v "$(pwd):/build" nandub/arch-pkgbuild
```

# How to build

```shell
  $ docker build -t nandub/arch-pkgbuild .
```

# Build options

Use a specific Arch base image when you need reproducible debugging:

```shell
  $ docker build --build-arg ARCH_IMAGE=archlinux:base -t nandub/arch-pkgbuild .
```

For packages whose dependencies all come from official Arch repositories, build
the smaller image that skips AUR dependency support:

```shell
  $ docker build -f Dockerfile.plain -t nandub/arch-pkgbuild:plain .
```

# Notes

This image intentionally keeps `base-devel` installed because Arch packages are
expected to build with those tools available. To export built package files back
to the mounted package directory, set `EXPORT_PKG=1`:

```shell
  $ docker run --rm -it -e EXPORT_PKG=1 -v "$(pwd):/build" nandub/arch-pkgbuild
```

The container updates packages before each build by default. For faster local
reruns against a freshly built image, set `UPDATE_SYSTEM=0`; when package
databases are missing, the script syncs databases without doing a full upgrade.

```shell
  $ docker run --rm -it -e UPDATE_SYSTEM=0 -v "$(pwd):/build" nandub/arch-pkgbuild
```

# Test

```powershell
  PS> .\scripts\Invoke-ArchPkgbuildTask.ps1 all
  PS> .\scripts\Test-ArchPkgbuild.ps1
  PS> .\scripts\Invoke-ShellCheck.ps1
```

Useful task shortcuts:

```powershell
  PS> .\scripts\Invoke-ArchPkgbuildTask.ps1 build
  PS> .\scripts\Invoke-ArchPkgbuildTask.ps1 build-plain
  PS> .\scripts\Invoke-ArchPkgbuildTask.ps1 sizes
```
