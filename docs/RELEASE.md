# Release procedure

1. Update `opusSdkVersion` in `gradle.properties`. Use
   `<opus-upstream-describe>-rN`, for example `1.6.1-96-g677070ed-r1`.
   Increase `rN` if JNI or packaging changes without an Opus source update.
2. If updating Opus, update the vendored source, `UPSTREAM.json`, this
   project's tests, and `docs/BUILDING.md` together.
3. Build with `scripts/build-aar.ps1` on a clean checkout.
4. Run `scripts/verify-aar.ps1` and preserve the printed SHA-256.
5. Tag the exact SDK repository commit as `v<opusSdkVersion>`.
6. Attach the AAR, SHA-256 file, build log, and SBOM to the release or publish
   them to the approved Maven registry.
7. Update the consumer application only to the released Maven coordinate.
