[CmdletBinding()]
param(
    [switch]$SkipClean
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot
$versionLine = Select-String -LiteralPath (Join-Path $repoRoot 'gradle.properties') -Pattern '^opusSdkVersion=(.+)$' |
    Select-Object -First 1
if ($null -eq $versionLine) {
    throw 'opusSdkVersion is missing from gradle.properties'
}
$sdkVersion = $versionLine.Matches[0].Groups[1].Value.Trim()

if (-not $SkipClean) {
    & .\gradlew.bat :opus-sdk:clean --no-daemon --max-workers=1
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

& .\gradlew.bat :opus-sdk:assembleRelease --no-daemon --max-workers=1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$artifactDirectory = Join-Path $repoRoot 'artifacts'
New-Item -ItemType Directory -Force -Path $artifactDirectory | Out-Null
$aar = Join-Path $repoRoot 'opus-sdk\build\outputs\aar\opus-sdk-release.aar'
$artifactName = "opus-android-sdk-$sdkVersion.aar"
$artifactPath = Join-Path $artifactDirectory $artifactName
Copy-Item -LiteralPath $aar -Destination $artifactPath -Force
& (Join-Path $PSScriptRoot 'verify-aar.ps1') -AarPath $artifactPath
