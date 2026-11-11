cmake_minimum_required(VERSION 3.16)

project(opus_android_jni LANGUAGES C)

# The pinned upstream source is part of this repository as a Git subtree. Its
# exact upstream repository and commit are recorded in third_party/opus-UPSTREAM.json.
get_filename_component(OPUS_SOURCE_DIR
        "${CMAKE_CURRENT_LIST_DIR}/../../../../third_party/opus" ABSOLUTE)
if(NOT EXISTS "${OPUS_SOURCE_DIR}/CMakeLists.txt")
    message(FATAL_ERROR "Opus source was not found at ${OPUS_SOURCE_DIR}")
endif()

# Opus's arm64 NEON assembly cannot be linked from a static archive into
# another shared library. Build its official target as a shared library and
# package it alongside the JNI facade to retain the optimized kernels.
set(OPUS_BUILD_SHARED_LIBRARY ON CACHE BOOL "" FORCE)
# The vendored source intentionally has no .git directory. Gradle passes this
# value from opusUpstreamDescribe, which is synchronized with the pinned
# subtree commit by scripts/sync-opus-version.ps1. Keep a standalone-CMake
# fallback without overriding the Gradle-provided cache value.
if(NOT DEFINED OPUS_PACKAGE_VERSION)
    set(OPUS_PACKAGE_VERSION "unknown" CACHE STRING "Pinned Opus source version")
endif()
set(OPUS_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(OPUS_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)
set(OPUS_INSTALL_PKG_CONFIG_MODULE OFF CACHE BOOL "" FORCE)
set(OPUS_INSTALL_CMAKE_CONFIG_MODULE OFF CACHE BOOL "" FORCE)

add_subdirectory("${OPUS_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/opus")

add_library(opus_jni SHARED opus_jni.c)
target_link_libraries(opus_jni PRIVATE opus log)
