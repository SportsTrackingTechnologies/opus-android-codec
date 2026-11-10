[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AarPath
)

$ErrorActionPreference = 'Stop'
$resolvedAar = (Resolve-Path -LiteralPath $AarPath).Path
$expectedAbis = @('arm64-v8a', 'armeabi-v7a', 'x86_64')

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedAar)
try {
    $entryNames = $archive.Entries.FullName
    foreach ($abi in $expectedAbis) {
        foreach ($library in @('libopus.so', 'libopus_jni.so')) {
            $entry = "jni/$abi/$library"
            if ($entryNames -notcontains $entry) {
                throw "Missing required native library: $entry"
            }
        }
    }
    $unexpectedLibraries = $entryNames | Where-Object {
        $_ -like 'jni/*' -and $_ -match '^jni/([^/]+)/'
    } | ForEach-Object {
        ($_ -split '/')[1]
    } | Select-Object -Unique | Where-Object { $_ -notin $expectedAbis }
    if ($unexpectedLibraries) {
        throw "Unexpected ABIs: $($unexpectedLibraries -join ', ')"
    }
} finally {
    $archive.Dispose()
}

$sha256 = [System.Security.Cryptography.SHA256]::Create()
try {
    $stream = [System.IO.File]::OpenRead($resolvedAar)
    try {
        $hashBytes = $sha256.ComputeHash($stream)
    } finally {
        $stream.Dispose()
    }
} finally {
    $sha256.Dispose()
}
$hashHex = -join ($hashBytes | ForEach-Object { $_.ToString('x2') })
$hashLine = "$hashHex  $([System.IO.Path]::GetFileName($resolvedAar))"
$hashPath = "$resolvedAar.sha256"
Set-Content -LiteralPath $hashPath -Value $hashLine -NoNewline
Write-Host "Verified $resolvedAar"
Write-Host $hashLine
