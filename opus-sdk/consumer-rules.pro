# JNI uses statically exported symbols derived from the Java class and native
# method names. Consumers must retain them when R8/ProGuard is enabled.
-keep class com.stt.opus.OpusEncoder { *; }
-keep class com.stt.opus.OpusDecoder { *; }
