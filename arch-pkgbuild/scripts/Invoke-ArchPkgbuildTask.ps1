[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('build', 'build-plain', 'test', 'shellcheck', 'sizes', 'all')]
    [string] $Task = 'all',

    [string] $Image = 'nandub/arch-pkgbuild',
    [string] $PlainImage = 'nandub/arch-pkgbuild:plain',
    [string] $ArchImage = 'archlinux:base'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

function Invoke-Native {
    param(
        [Parameter(Mandatory)]
        [string] $FilePath,

        [Parameter(Mandatory)]
        [string[]] $ArgumentList
    )

    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath exited with code $LASTEXITCODE"
    }
}

function Invoke-Build {
    Invoke-Native -FilePath docker -ArgumentList @(
        'build',
        '--build-arg', "ARCH_IMAGE=$ArchImage",
        '-t', $Image,
        $root
    )
}

function Invoke-BuildPlain {
    Invoke-Native -FilePath docker -ArgumentList @(
        'build',
        '--build-arg', "ARCH_IMAGE=$ArchImage",
        '-f', (Join-Path $root 'Dockerfile.plain'),
        '-t', $PlainImage,
        $root
    )
}

switch ($Task) {
    'build' {
        Invoke-Build
    }

    'build-plain' {
        Invoke-BuildPlain
    }

    'test' {
        & (Join-Path $PSScriptRoot 'Test-ArchPkgbuild.ps1') -FullImage $Image -PlainImage $PlainImage -ArchImage $ArchImage
    }

    'shellcheck' {
        & (Join-Path $PSScriptRoot 'Invoke-ShellCheck.ps1')
    }

    'sizes' {
        Invoke-Native -FilePath docker -ArgumentList @(
            'images',
            '--format', 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.ID}}',
            'nandub/arch-pkgbuild'
        )
    }

    'all' {
        & (Join-Path $PSScriptRoot 'Invoke-ShellCheck.ps1')
        & (Join-Path $PSScriptRoot 'Test-ArchPkgbuild.ps1') -FullImage $Image -PlainImage $PlainImage -ArchImage $ArchImage
        Invoke-Native -FilePath docker -ArgumentList @(
            'images',
            '--format', 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.ID}}',
            'nandub/arch-pkgbuild'
        )
    }
}
