[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Tag
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$propertiesPath = Join-Path $repoRoot 'gradle.properties'

function Get-RequiredProperty([string]$Name) {
    $line = Select-String -LiteralPath $propertiesPath -Pattern "^$Name=(.+)$" |
        Select-Object -First 1
    if ($null -eq $line) { throw "$Name is missing from gradle.properties" }
    return $line.Matches[0].Groups[1].Value.Trim()
}

$expectedVersion = "$(Get-RequiredProperty 'opusUpstreamDescribe')-r$(Get-RequiredProperty 'opusWrapperRevision')"
$expectedTag = "v$expectedVersion"
if ($Tag -ne $expectedTag) {
    throw "Release tag '$Tag' does not match the derived SDK version. Expected '$expectedTag'."
}

Write-Host "Verified release tag $Tag"
