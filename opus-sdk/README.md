# Opus Android SDK

This Android library builds the adjacent official source checkout at
`D:/7006/AndroidProject/opus` with NDK `30.0.16248370` and CMake `3.22.1`.

Build the release AAR from the repository root:

```powershell
.\gradlew.bat :opus-sdk:assembleRelease
```

The resulting artifact is `opus-sdk/build/outputs/aar/opus-sdk-release.aar`.
It packages `libopus_jni.so` and the official `libopus.so` for `arm64-v8a`,
`armeabi-v7a`, and `x86_64`.

## Local integration

For a module in this project:

```kotlin
dependencies {
    implementation(project(":opus-sdk"))
}
```

For an external project, copy the generated AAR into its `libs/` directory and
add it as an AAR dependency.

## Decode a 20 ms frame at 48 kHz

```java
byte[] receiveBuffer = new byte[1500];
short[] outputPcm = new short[960];

try (OpusDecoder decoder = new OpusDecoder(48_000, 1)) {
    int decodedSamples = decoder.decode(
            receiveBuffer, 0, receivedLength,
            outputPcm, 0, 960, false);
    // When a packet is lost, use decoder.decodePlc(outputPcm, 0, 960).
    // Call decoder.resetState() before reusing it for a new voice session.
}
```

`close()` releases the native encoder or decoder; use try-with-resources as
shown above. The SDK includes the Opus license in `META-INF/LICENSE-opus.txt`.
