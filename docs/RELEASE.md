# Release procedure

1. Run `scripts/sync-opus-version.ps1` after each subtree upgrade. It derives
   the official Opus describe value and updates pinned provenance metadata.
2. Increase `opusWrapperRevision` in `gradle.properties` if JNI or packaging
   changes without an Opus source update. The AAR version is derived as
   `<opus-upstream-describe>-rN`, for example `1.6.1-96-g677070ed0-r5`.
3. If updating Opus, update the vendored source, `UPSTREAM.json`, this
   project's tests, and `docs/BUILDING.md` together.
4. Build with `scripts/build-aar.ps1` on a clean checkout.
5. Run `scripts/verify-aar.ps1` and preserve the printed SHA-256.
6. Tag the exact SDK repository commit as `v<opus-upstream-describe>-rN`.
7. Push the exact release tag to trigger GitHub Actions publication:

   ```powershell
   rtk proxy git tag v<opus-upstream-describe>-rN
   rtk proxy git push origin v<opus-upstream-describe>-rN
   ```

   The workflow first runs `Build AAR`, then publishes the release AAR to JFrog
   only if that job succeeds. It requires one-time administrator configuration:
   `ARTIFACTORY_USER` and `ARTIFACTORY_PASSWORD` Actions Secrets, plus the
   `ARTIFACTORY_CONTEXT_URL` Actions Variable. Do not use local publishing as
   the normal release mechanism.
8. Update the consumer application only to the released Maven coordinate.
