[CmdletBinding()]
param(
    [string] $Image = 'koalaman/shellcheck:stable'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$mountPath = $root -replace '\\', '/'

docker run --rm -v "${mountPath}:/mnt" $Image /mnt/pkg.sh
