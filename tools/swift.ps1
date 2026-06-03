<#
.SYNOPSIS
    Kører Swift (build/test/...) i et korrekt opsat Swift-for-Windows-miljø.

.DESCRIPTION
    Swift på Windows kræver tre ting ud over selve toolchainen:
      1. Runtime-DLL'erne (swiftCore.dll, Foundation.dll ...) på PATH.
      2. SDKROOT peget på Windows.sdk i Platforms-mappen.
      3. Visual Studios C++-miljø (link.exe, ucrt, Windows SDK-libs) aktiveret,
         så linkeren virker.

    Dette script samler det hele og videresender alle argumenter til swift.exe.

.EXAMPLE
    pwsh -File tools/swift.ps1 build
    pwsh -File tools/swift.ps1 test --package-path StjernelobCore
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $SwiftArgs
)

$ErrorActionPreference = 'Stop'

# --- 1. Find Swift-toolchain + runtime --------------------------------------
$swiftRoot = Join-Path $env:LOCALAPPDATA 'Programs\Swift'
$toolchainBin = Get-ChildItem -Path (Join-Path $swiftRoot 'Toolchains') -Directory |
    Sort-Object Name -Descending | Select-Object -First 1 |
    ForEach-Object { Join-Path $_.FullName 'usr\bin' }
$runtimeBin = Get-ChildItem -Path (Join-Path $swiftRoot 'Runtimes') -Directory |
    Sort-Object Name -Descending | Select-Object -First 1 |
    ForEach-Object { Join-Path $_.FullName 'usr\bin' }

if (-not (Test-Path (Join-Path $toolchainBin 'swift.exe'))) {
    throw "Fandt ikke swift.exe under $toolchainBin"
}

# --- 2. SDKROOT (Windows-platform-SDK) --------------------------------------
$platform = Get-ChildItem -Path (Join-Path $swiftRoot 'Platforms') -Directory |
    Sort-Object Name -Descending | Select-Object -First 1
$sdkRoot = Join-Path $platform.FullName 'Windows.platform\Developer\SDKs\Windows.sdk'
if (-not (Test-Path $sdkRoot)) {
    throw "Fandt ikke Windows.sdk under $sdkRoot"
}
$env:SDKROOT = $sdkRoot

# --- 3. Aktivér Visual Studios C++-miljø (for linkeren) ---------------------
# Vælg den VS-instans (Build Tools eller fuld VS), der faktisk har MSVC-
# linkeren på disken. Vi stoler ikke på `vswhere -requires`, da Build Tools
# registrerer workload'en frem for komponent-ID'et.
$installerDir = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer'
$env:PATH = "$installerDir;$env:PATH"   # så Enter-VsDevShell selv kan finde vswhere
$vswhere = Join-Path $installerDir 'vswhere.exe'
$instances = & $vswhere -all -products * -property installationPath
$vsPath = $instances | Where-Object {
    Test-Path (Join-Path $_ 'VC\Tools\MSVC')
} | Select-Object -First 1
if (-not $vsPath) {
    throw "Ingen VS-installation med C++-toolset (VC\Tools\MSVC) fundet. Installer 'Desktop development with C++' eller VS Build Tools med VCTools."
}
$devShell = Join-Path $vsPath 'Common7\Tools\Microsoft.VisualStudio.DevShell.dll'
Import-Module $devShell
Enter-VsDevShell -VsInstallPath $vsPath -SkipAutomaticLocation `
    -DevCmdArguments '-arch=x64 -host_arch=x64' | Out-Null

# --- 4. PATH og kør ----------------------------------------------------------
$env:PATH = "$toolchainBin;$runtimeBin;$env:PATH"

& (Join-Path $toolchainBin 'swift.exe') @SwiftArgs
exit $LASTEXITCODE
