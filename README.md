# Opus Android SDK

Reproducible Android AAR packaging for the pinned Opus reference
implementation and a small JNI decoder wrapper.

## Build

Install the versions in [docs/BUILDING.md](docs/BUILDING.md), then run:

```powershell
.\scripts\build-aar.ps1
```

The output is `artifacts/opus-android-sdk-<version>.aar`, accompanied by a
SHA-256 checksum. The SDK ships `arm64-v8a`, `armeabi-v7a`, and `x86_64` native
libraries. Edit `opus-sdk/build.gradle.kts` if the supported ABI set changes.

## Maven consumption

This repository is prepared for JitPack. Create and push an immutable Git tag,
then use the JitPack coordinate displayed for that tag. The published Android
artifact is `opus-android-sdk`; it contains both JNI shared libraries for each
supported ABI and the Java decoder API.

## Provenance

The upstream Opus source is integrated as a Git subtree at `third_party/opus`;
its source repository and pinned commit are recorded in
[`third_party/opus-UPSTREAM.json`](third_party/opus-UPSTREAM.json). JNI source
is maintained at `opus-sdk/src/main/cpp/opus_jni.c`.

## License

Opus is redistributed under its three-clause BSD license. See
[`NOTICE`](NOTICE), [`third_party/opus/COPYING`](third_party/opus/COPYING), and
[`licenses/opus/NOTICE.md`](licenses/opus/NOTICE.md). Products distributing the
AAR must include the applicable notice in their open-source notices.
