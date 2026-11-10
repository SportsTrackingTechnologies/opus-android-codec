# Release procedure

1. Run `scripts/sync-opus-version.ps1` after each subtree upgrade. It derives
   the official Opus describe value and updates pinned provenance metadata.
2. Increase `opusWrapperRevision` in `gradle.properties` if JNI or packaging
   changes without an Opus source update. The AAR version is derived as
   `<opus-upstream-describe>-rN`, for example `1.6.1-96-g677070ed0-r4`.
2. If updating Opus, update the vendored source, `UPSTREAM.json`, this
   project's tests, and `docs/BUILDING.md` together.
3. Build with `scripts/build-aar.ps1` on a clean checkout.
4. Run `scripts/verify-aar.ps1` and preserve the printed SHA-256.
5. Tag the exact SDK repository commit as `v<opusSdkVersion>`.
6. Attach the AAR, SHA-256 file, build log, and SBOM to the release or publish
   them to the approved Maven registry.
7. Update the consumer application only to the released Maven coordinate.
