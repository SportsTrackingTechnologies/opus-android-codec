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

The SDK is published to the company JFrog Artifactory Maven repository. Client
applications should use the company's standard Gradle/JFrog repository setup,
then depend on the SDK using its version derived from the pinned Opus source:

```kotlin
dependencies {
    implementation("com.stt.opus:opus-android-sdk:1.6.1-96-g677070ed0-r5")
}
```

## Release publishing

Normal releases are published only by GitHub Actions. A maintainer validates
the release locally, then pushes a version tag matching the derived SDK
version, for example `v1.6.1-96-g677070ed0-r5`. The workflow builds and
verifies the AAR first, then publishes it to the company JFrog release
repository. Publishing credentials are held only in GitHub Actions Secrets;
they are never configured in this repository or shared with consumers.

The one-time GitHub configuration is documented in
[`docs/RELEASE.md`](docs/RELEASE.md).

## Provenance

The upstream Opus source is integrated as a Git subtree at `third_party/opus`;
its source repository and pinned commit are recorded in
[`third_party/opus-UPSTREAM.json`](third_party/opus-UPSTREAM.json). JNI source
is maintained at `opus-sdk/src/main/cpp/opus_jni.c`.

## License

Opus is redistributed under its three-clause BSD license. See
[`LICENSE`](LICENSE), [`NOTICE`](NOTICE),
[`third_party/opus/COPYING`](third_party/opus/COPYING), and
[`licenses/opus/NOTICE.md`](licenses/opus/NOTICE.md). Products distributing the
AAR must include the applicable notice in their open-source notices.
