plugins {
    alias(libs.plugins.android.library)
    `maven-publish`
}

// Keep the default coordinate stable for the company Maven repository. A
// deliberate override is available for approved snapshot/release workflows.
group = providers.gradleProperty("opusMavenGroup").getOrElse("com.stt.opus")
val derivedVersion = "${providers.gradleProperty("opusUpstreamDescribe").get()}-r${providers.gradleProperty("opusWrapperRevision").get()}"
version = providers.gradleProperty("opusPublishVersion")
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

        externalNativeBuild {
            cmake {
                // Keep the native Opus metadata aligned with the pinned
                // subtree version used for the published AAR.
                arguments += "-DOPUS_PACKAGE_VERSION=${providers.gradleProperty("opusUpstreamDescribe").get()}"
            }
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
                pom {
                    name.set("Opus Android SDK")
                    description.set("Android AAR packaging of pinned Opus source with a JNI decoder API.")
                    url.set("https://github.com/SportsTrackingTechnologies/AndroidOpus")
                    licenses {
                        license {
                            name.set("BSD 3-Clause License (Opus)")
                            url.set("https://opus-codec.org/license/")
                            distribution.set("repo")
                        }
                    }
                    scm {
                        connection.set("scm:git:https://github.com/SportsTrackingTechnologies/AndroidOpus.git")
                        developerConnection.set("scm:git:ssh://git@github.com/SportsTrackingTechnologies/AndroidOpus.git")
                        url.set("https://github.com/SportsTrackingTechnologies/AndroidOpus")
                    }
                }
            }
        }
    }
}

publishing {
    repositories {
        maven {
            name = "jfrog"
            val repositoryBaseUrl = "https://sally01.jfrog.io/sally01"
            val releaseRepositoryUrl = "$repositoryBaseUrl/amersports-release-local"
            val snapshotRepositoryUrl = "$repositoryBaseUrl/amersports-snapshot-local"
            url = uri(
                if (version.toString().endsWith("-SNAPSHOT", ignoreCase = true)) {
                    snapshotRepositoryUrl
                } else {
                    releaseRepositoryUrl
                }
            )
            credentials {
                username = providers.gradleProperty("artifactory_user").orNull
                password = providers.gradleProperty("artifactory_password").orNull
            }
        }
    }
}
