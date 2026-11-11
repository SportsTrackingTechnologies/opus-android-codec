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

The SDK is published to the company JFrog Artifactory Maven repository. Its
default coordinate is derived from the pinned Opus source, for example:

```kotlin
val artifactoryContextUrl = providers.gradleProperty("artifactory_contextUrl").get()

repositories {
    maven {
        url = uri("$artifactoryContextUrl/amersports-release-local")
        credentials {
            username = providers.gradleProperty("artifactory_user").orNull
            password = providers.gradleProperty("artifactory_password").orNull
        }
    }
}

dependencies {
    implementation("com.stt.opus:opus-android-sdk:1.6.1-96-g677070ed0-r5")
}
```

Repository credentials belong in the developer's `~/.gradle/gradle.properties`
or CI configuration, never in this repository. Configure the local file as
follows (use the company-provided credentials):

```properties
artifactory_contextUrl=https\://sally01.jfrog.io/sally01
artifactory_user=...
artifactory_password=...
```

Release versions publish to `amersports-release-local`; versions ending in
`-SNAPSHOT` publish to `amersports-snapshot-local`.

To publish a release after validation:

```powershell
.\gradlew.bat :opus-sdk:publishReleasePublicationToJfrogRepository
```

For tag-based CI publishing, configure repository or organization secrets
`ARTIFACTORY_USER` and `ARTIFACTORY_PASSWORD`, plus an
`ARTIFACTORY_CONTEXT_URL` GitHub Actions Variable. A pushed `v*` tag first runs
the release build and AAR verification, then publishes only if that build
succeeds.

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
