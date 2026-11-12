# Release procedure

1. Review [`VERSIONING.md`](VERSIONING.md), then run
   `scripts/sync-opus-version.ps1` after each subtree upgrade. It derives
   the official Opus describe value and updates pinned provenance metadata.
2. Increase `opusWrapperRevision` in `gradle.properties` if JNI or packaging
   changes without an Opus source update. The AAR version is derived as
   `<opus-upstream-describe>-rN`, for example `1.6.1-96-g677070ed0-r6`.
3. If updating Opus, update the vendored source, `UPSTREAM.json`, this
   project's tests, and `docs/BUILDING.md` together.
4. Build with `scripts/build-aar.ps1` on a clean checkout.
5. Run `scripts/verify-aar.ps1` and preserve the printed SHA-256.
6. Configure the authorized maintainer's `~/.gradle/gradle.properties` with:

   ```properties
   artifactory_contextUrl=https\://sally01.jfrog.io/sally01
   artifactory_user=...
   artifactory_password=...
   ```

7. Publish manually to the company JFrog release repository:

   ```powershell
   .\gradlew.bat publishAll
   ```

   `publishAll` uploads the release AAR, sources JAR, Maven POM, and Gradle
   module metadata. Do not reuse an already published release version.

8. Verify and push the exact release tag after successful publication:

   ```powershell
   .\scripts\verify-release-tag.ps1 -Tag v<opus-upstream-describe>-rN
   git tag v<opus-upstream-describe>-rN
   git push origin v<opus-upstream-describe>-rN
   ```

9. Update the consumer application only to the released Maven coordinate.
