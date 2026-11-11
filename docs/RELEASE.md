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
7. Publish the release AAR to the company JFrog repository:

   ```powershell
   .\gradlew.bat :opus-sdk:publishReleasePublicationToJfrogRepository
   ```

   Versions ending in `-SNAPSHOT` are routed to the snapshot repository; use
   `-PopusPublishVersion=<derived-version>-SNAPSHOT` only for non-release
   validation builds.
   The local user Gradle properties must provide `artifactory_contextUrl`,
   `artifactory_user`, and `artifactory_password`. For CI publication, create
   `ARTIFACTORY_USER` and `ARTIFACTORY_PASSWORD` repository or organization
   secrets plus an `ARTIFACTORY_CONTEXT_URL` Actions Variable before pushing
   the release tag. The GitHub Actions workflow publishes only after its Build
   AAR job succeeds.
8. Update the consumer application only to the released Maven coordinate.
