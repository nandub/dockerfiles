[CmdletBinding()]
param(
    [string] $FullImage = 'nandub/arch-pkgbuild:test',
    [string] $PlainImage = 'nandub/arch-pkgbuild:plain-test',
    [string] $ArchImage = 'archlinux:base',
    [switch] $SkipBuild
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path $root 'test-output\hello'
$pkgbuild = Join-Path $root 'tests\hello\PKGBUILD'

function Invoke-Native {
    param(
        [Parameter(Mandatory)]
        [string] $FilePath,

        [Parameter(Mandatory)]
        [string[]] $ArgumentList
    )

    & $FilePath @ArgumentList | ForEach-Object {
        Write-Host $_
    }

    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath exited with code $LASTEXITCODE"
    }
}

if (-not (Test-Path -LiteralPath $pkgbuild)) {
    throw "Missing smoke-test PKGBUILD: $pkgbuild"
}

Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $testRoot | Out-Null

if (-not $SkipBuild) {
    Invoke-Native -FilePath docker -ArgumentList @('build', '--build-arg', "ARCH_IMAGE=$ArchImage", '-t', $FullImage, $root)
    Invoke-Native -FilePath docker -ArgumentList @('build', '--build-arg', "ARCH_IMAGE=$ArchImage", '-f', (Join-Path $root 'Dockerfile.plain'), '-t', $PlainImage, $root)
}

function Invoke-SmokeBuild {
    param(
        [Parameter(Mandatory)]
        [string] $Image,

        [Parameter(Mandatory)]
        [string] $Name
    )

    $testBuild = Join-Path $testRoot $Name
    New-Item -ItemType Directory -Path $testBuild | Out-Null
    Copy-Item -LiteralPath $pkgbuild -Destination (Join-Path $testBuild 'PKGBUILD')

    $mountPath = $testBuild -replace '\\', '/'
    Invoke-Native -FilePath docker -ArgumentList @('run', '--rm', '-e', 'EXPORT_PKG=1', '-e', 'UPDATE_SYSTEM=0', '-v', "${mountPath}:/build", $Image)

    $packages = Get-ChildItem -LiteralPath $testBuild -Filter '*.pkg.tar.*' -File
    if ($packages.Count -lt 1) {
        throw "Smoke test for $Name did not export a package into $testBuild"
    }

    return $packages
}

$packages = @()
$packages += Invoke-SmokeBuild -Image $FullImage -Name 'full'
$packages += Invoke-SmokeBuild -Image $PlainImage -Name 'plain'

Write-Host "Smoke test passed. Exported package(s):"
$packages | ForEach-Object { Write-Host "  $($_.Name)" }
