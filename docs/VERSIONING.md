# SDK versioning

The SDK version is derived from the pinned Opus subtree version and the Android
wrapper revision:

```text
<opus-upstream-describe>-r<wrapper-revision>
```

For example:

```text
1.6.1-96-g677070ed0-r5
```

| Part | Meaning |
| --- | --- |
| `1.6.1` | Nearest official upstream Opus tag. |
| `96` | Number of upstream commits after that tag. |
| `g677070ed0` | Abbreviated pinned upstream Opus commit. |
| `r5` | SDK wrapper/build revision maintained in this repository. |

`scripts/sync-opus-version.ps1` derives the first three parts from the latest
Opus Git subtree update and writes `opusUpstreamCommit` and
`opusUpstreamDescribe` to `gradle.properties`.

Increase `opusWrapperRevision` whenever a change can affect the published SDK
without changing the upstream Opus commit, including changes to Java APIs, JNI,
CMake/Gradle packaging, ABI support, compiler options, licenses packaged in the
AAR, or build verification rules.

Each release tag must be exactly `v<SDK version>`, for example
`v1.6.1-96-g677070ed0-r5`. GitHub Actions verifies this before publication, so
the tag, Maven POM, AAR filename, and recorded source provenance remain
traceable to the same SDK version.
