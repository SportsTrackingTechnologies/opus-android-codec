[CmdletBinding()]
param(
    [switch]$FetchUpstream
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$metadataPath = Join-Path $repoRoot 'third_party\opus-UPSTREAM.json'
$propertiesPath = Join-Path $repoRoot 'gradle.properties'

$subtreeMessage = (& git -c "safe.directory=$repoRoot" -C $repoRoot log --format=%B --all --grep='git-subtree-split:') -join "`n"
if ($LASTEXITCODE -ne 0 -or $subtreeMessage -notmatch 'git-subtree-split:\s*([0-9a-f]{40})') {
    throw 'Could not find a git-subtree-split commit for third_party/opus.'
}
$commit = $Matches[1]

if ($FetchUpstream) {
    & git -c "safe.directory=$repoRoot" -C $repoRoot fetch opus-upstream --tags
    if ($LASTEXITCODE -ne 0) { throw 'Fetching opus-upstream tags failed.' }
}

$describe = & git -c "safe.directory=$repoRoot" -C $repoRoot describe --tags --match 'v[0-9]*' --always $commit
if ($LASTEXITCODE -ne 0 -or $describe -match '^[0-9a-f]+$') {
    throw 'The pinned commit is not connected to a cached official Opus tag. Run with -FetchUpstream.'
}
$describe = $describe.Trim() -replace '^v', ''

$metadata = [ordered]@{
    name = 'Opus'
    repository = 'https://github.com/xiph/opus.git'
    commit = $commit
    describe = $describe
    integration = 'git subtree --squash'
    licenseFile = 'COPYING'
}
$metadata | ConvertTo-Json | Set-Content -LiteralPath $metadataPath

$properties = Get-Content -LiteralPath $propertiesPath -Raw
$properties = [regex]::Replace($properties, '(?m)^opusUpstreamCommit=.*$', "opusUpstreamCommit=$commit")
$properties = [regex]::Replace($properties, '(?m)^opusUpstreamDescribe=.*$', "opusUpstreamDescribe=$describe")
Set-Content -LiteralPath $propertiesPath -Value $properties -NoNewline

$revision = ([regex]::Match($properties, '(?m)^opusWrapperRevision=(.+)$')).Groups[1].Value.Trim()
Write-Host "Pinned Opus: $describe ($commit)"
Write-Host "Derived SDK version: $describe-r$revision"
