# Opus Android SDK

Repeatable Android AAR packaging for the pinned Opus reference
implementation and a small JNI decoder wrapper.

## Build

Install the versions in [docs/BUILDING.md](docs/BUILDING.md), then run:

```powershell
.\scripts\build-aar.ps1
```

The output is `artifacts/opus-android-sdk-<version>.aar`, accompanied by a
SHA-256 checksum. The SDK ships `arm64-v8a`, `armeabi-v7a`, and `x86_64` native
libraries. This ABI set intentionally excludes 32-bit `x86`; `x86_64` is kept
for 64-bit emulator coverage. The build verification also checks 16 KB ELF LOAD
alignment for the 64-bit native libraries (`arm64-v8a` and `x86_64`). This AAR
check does not replace final APK/AAB ZIP-alignment validation by each consuming
application.

The supported ABI set is defined by the Android library and native build
configurations. Update the relevant Gradle, CMake/native build, and verification
configurations together if the supported ABI set changes.

## Maven consumption

The SDK is published to the company JFrog Artifactory Maven repository. Client
applications should use the company's standard Gradle/JFrog repository setup,
then depend on the SDK using a released version:

```kotlin
dependencies {
    implementation("com.stt.opus:opus-android-sdk:<version>")
}
```

Replace `<version>` with the published SDK version. The SDK version identifies
the pinned upstream Opus revision and the Android wrapper revision; its
components and derivation rules are defined in `gradle.properties` and
documented in [`docs/VERSIONING.md`](docs/VERSIONING.md).

## Release publishing

Normal releases are published only by GitHub Actions. A maintainer validates
the release locally, then pushes a version tag matching the derived SDK version,
for example `v1.6.1-96-g677070ed0-r5`. The workflow builds and verifies the AAR
first, then publishes it to the company JFrog release repository. JFrog
publishing credentials are stored exclusively in GitHub Actions Secrets; they
are never committed to this repository or distributed to SDK consumers.

The CI workflow rejects a release tag that does not exactly match the SDK
version derived from `gradle.properties`. See
[`docs/VERSIONING.md`](docs/VERSIONING.md) for the version format and revision
rules.

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
