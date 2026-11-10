# Building the AAR

## Pinned inputs

| Input | Value |
| --- | --- |
| Opus upstream | `https://github.com/xiph/opus.git` |
| Opus commit | `677070ed0c35fc52a634f4be845aa426ea3a1689` |
| Opus describe | `okv1.6.1-96-g677070ed` |
| Android NDK | `30.0.16248370` |
| CMake | `3.22.1` |
| Gradle | `9.5.0` |
| Android Gradle Plugin | `9.3.3` |
| Java | 17 |
| minSdk | 24 |
| ABI | `arm64-v8a`, `armeabi-v7a`, `x86_64` |

The Opus subtree snapshot is recorded in `third_party/opus/UPSTREAM.json`.
Its commit and source state must be updated in the same commit as any upstream
source upgrade.

## Native options

The JNI CMake wrapper enables `OPUS_BUILD_SHARED_LIBRARY=ON` and disables
tests, programs, pkg-config installation, and CMake package installation.
The shared library is necessary because the arm64 NEON assembly cannot be
relinked from a static archive into `libopus_jni.so`.

## Build

Install the exact NDK and CMake above through Android SDK Manager, then run:

```powershell
.\scripts\build-aar.ps1
```

The artifact is written to `artifacts/opus-android-sdk-<opusSdkVersion>.aar`.
Run `scripts/verify-aar.ps1` to verify the ABI set and emit a SHA-256 checksum.
