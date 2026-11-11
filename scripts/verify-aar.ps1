[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AarPath
)

$ErrorActionPreference = 'Stop'
$resolvedAar = (Resolve-Path -LiteralPath $AarPath).Path
$expectedAbis = @('arm64-v8a', 'armeabi-v7a', 'x86_64')
$pageSizeAbis = @('arm64-v8a', 'x86_64')
$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-AndroidSdkRoot {
    if ($env:ANDROID_HOME) { return $env:ANDROID_HOME }
    if ($env:ANDROID_SDK_ROOT) { return $env:ANDROID_SDK_ROOT }

    $localPropertiesPath = Join-Path $repoRoot 'local.properties'
    if (Test-Path -LiteralPath $localPropertiesPath) {
        $sdkDirLine = Select-String -LiteralPath $localPropertiesPath -Pattern '^sdk\.dir=(.+)$' |
            Select-Object -First 1
        if ($sdkDirLine) {
            return ($sdkDirLine.Matches[0].Groups[1].Value -replace '\\:', ':' -replace '\\\\', '\\')
        }
    }

    $defaultSdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
    if (Test-Path -LiteralPath $defaultSdkRoot) { return $defaultSdkRoot }
    throw 'Android SDK path was not found. Set ANDROID_HOME or ANDROID_SDK_ROOT.'
}

function Get-ObjdumpPath {
    $ndkVersionLine = Select-String -LiteralPath (Join-Path $repoRoot 'gradle.properties') -Pattern '^opusNdkVersion=(.+)$' |
        Select-Object -First 1
    if ($null -eq $ndkVersionLine) { throw 'opusNdkVersion is missing from gradle.properties' }
    $ndkVersion = $ndkVersionLine.Matches[0].Groups[1].Value.Trim()
    $objdumpPath = Join-Path (Get-AndroidSdkRoot) "ndk\$ndkVersion\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-objdump.exe"
    if (-not (Test-Path -LiteralPath $objdumpPath)) {
        throw "llvm-objdump.exe was not found for NDK $ndkVersion at $objdumpPath"
    }
    return $objdumpPath
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedAar)
$temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "opus-aar-$([System.Guid]::NewGuid())"
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

    # Android's 16 KB page-size requirement applies to 64-bit native
    # libraries. NDK r28+ emits 16 KB ELF alignment by default; inspect the
    # actual AAR contents rather than relying only on the toolchain version.
    $objdumpPath = Get-ObjdumpPath
    New-Item -ItemType Directory -Force -Path $temporaryDirectory | Out-Null
    foreach ($abi in $pageSizeAbis) {
        foreach ($library in @('libopus.so', 'libopus_jni.so')) {
            $entryName = "jni/$abi/$library"
            $entry = $archive.Entries | Where-Object { $_.FullName -eq $entryName } | Select-Object -First 1
            $temporaryLibraryPath = Join-Path $temporaryDirectory "$abi-$library"
            $entryStream = $entry.Open()
            try {
                $outputStream = [System.IO.File]::Create($temporaryLibraryPath)
                try {
                    $entryStream.CopyTo($outputStream)
                } finally {
                    $outputStream.Dispose()
                }
            } finally {
                $entryStream.Dispose()
            }

            $loadLines = & $objdumpPath -p $temporaryLibraryPath | Select-String -Pattern '^\s*LOAD\s'
            if ($LASTEXITCODE -ne 0 -or -not $loadLines) {
                throw "Could not inspect ELF LOAD segments for $entryName"
            }
            $misalignedLines = $loadLines | Where-Object {
                $_.Line -notmatch 'align\s+2\*\*(1[4-9]|[2-9][0-9])\s*$'
            }
            if ($misalignedLines) {
                throw "16 KB ELF alignment check failed for ${entryName}: $($misalignedLines.Line -join '; ')"
            }
        }
    }
} finally {
    $archive.Dispose()
    if (Test-Path -LiteralPath $temporaryDirectory) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
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
Write-Host "Verified 16 KB ELF LOAD alignment for arm64-v8a and x86_64 native libraries"
Write-Host $hashLine
