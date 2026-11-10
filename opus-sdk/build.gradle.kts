plugins {
    alias(libs.plugins.android.library)
    `maven-publish`
}

// Keep the normal local/repository coordinate, but honor JitPack's injected
// group so consumers can resolve com.github.cz-2641:opus-android-sdk:<tag>.
group = providers.gradleProperty("group").getOrElse("com.stt.opus")
val derivedVersion = "${providers.gradleProperty("opusUpstreamDescribe").get()}-r${providers.gradleProperty("opusWrapperRevision").get()}"
// JitPack supplies the requested Git tag through VERSION (or -Pversion). Use
// it for the published POM so its Maven coordinate matches the immutable tag.
version = providers.gradleProperty("version")
    .orElse(providers.environmentVariable("VERSION"))
    .getOrElse(derivedVersion)

android {
    // Must differ from the consuming application's namespace. The public
    // Java/JNI API remains com.stt.opus.*.
    namespace = "com.stt.opus.sdk"
    compileSdk {
        version = release(36) {
            minorApiLevel = 1
        }
    }

    defaultConfig {
        minSdk = 24
        consumerProguardFiles("consumer-rules.pro")

        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    ndkVersion = providers.gradleProperty("opusNdkVersion").get()

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = providers.gradleProperty("opusCmakeVersion").get()
        }
    }

    buildTypes {
        release {
            optimization {
                enable = false
            }
        }
    }

    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

afterEvaluate {
    publishing {
        publications {
            register<MavenPublication>("release") {
                from(components["release"])
                artifactId = "opus-android-sdk"
            }
        }
    }
}
