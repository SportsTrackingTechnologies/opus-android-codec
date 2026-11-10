#include <jni.h>
#include <stdint.h>
#include <opus.h>

static void throw_exception(JNIEnv *env, const char *class_name, const char *message) {
  jclass exception_class = (*env)->FindClass(env, class_name);
  if (exception_class != NULL) {
    (*env)->ThrowNew(env, exception_class, message);
  }
}

static void throw_opus_error(JNIEnv *env, int error) {
  throw_exception(env, "java/lang/IllegalArgumentException", opus_strerror(error));
}

JNIEXPORT jlong JNICALL
Java_com_stt_opus_OpusEncoder_nativeCreate(JNIEnv *env, jclass clazz, jint sample_rate,
                                             jint channels, jint application) {
  (void) clazz;
  int error = OPUS_OK;
  OpusEncoder *encoder = opus_encoder_create(sample_rate, channels, application, &error);
  if (encoder == NULL) {
    throw_opus_error(env, error);
    return 0;
  }
  return (jlong) (intptr_t) encoder;
}

JNIEXPORT void JNICALL
Java_com_stt_opus_OpusEncoder_nativeDestroy(JNIEnv *env, jclass clazz, jlong handle) {
  (void) env;
  (void) clazz;
  if (handle != 0) opus_encoder_destroy((OpusEncoder *) (intptr_t) handle);
}

JNIEXPORT jint JNICALL
Java_com_stt_opus_OpusEncoder_nativeEncode(JNIEnv *env, jclass clazz, jlong handle,
                                             jshortArray pcm, jint frame_size,
                                             jbyteArray packet) {
  (void) clazz;
  if (handle == 0) {
    throw_exception(env, "java/lang/IllegalStateException", "Encoder is closed");
    return 0;
  }
  jshort *pcm_data = (*env)->GetShortArrayElements(env, pcm, NULL);
  jbyte *packet_data = (*env)->GetByteArrayElements(env, packet, NULL);
  if (pcm_data == NULL || packet_data == NULL) return 0;
  int result = opus_encode((OpusEncoder *) (intptr_t) handle, pcm_data, frame_size,
                           (unsigned char *) packet_data,
                           (*env)->GetArrayLength(env, packet));
  (*env)->ReleaseShortArrayElements(env, pcm, pcm_data, JNI_ABORT);
  (*env)->ReleaseByteArrayElements(env, packet, packet_data, 0);
  if (result < OPUS_OK) {
    throw_opus_error(env, result);
    return 0;
  }
  return result;
}

JNIEXPORT void JNICALL
Java_com_stt_opus_OpusEncoder_nativeSetBitrate(JNIEnv *env, jclass clazz, jlong handle,
                                                 jint bitrate) {
  (void) clazz;
  if (handle == 0) {
    throw_exception(env, "java/lang/IllegalStateException", "Encoder is closed");
    return;
  }
  int result = opus_encoder_ctl((OpusEncoder *) (intptr_t) handle, OPUS_SET_BITRATE(bitrate));
  if (result != OPUS_OK) throw_opus_error(env, result);
}

JNIEXPORT jlong JNICALL
Java_com_stt_opus_OpusDecoder_nativeCreate(JNIEnv *env, jclass clazz, jint sample_rate,
                                             jint channels) {
  (void) clazz;
  int error = OPUS_OK;
  OpusDecoder *decoder = opus_decoder_create(sample_rate, channels, &error);
  if (decoder == NULL) {
    throw_opus_error(env, error);
    return 0;
  }
  return (jlong) (intptr_t) decoder;
}

JNIEXPORT void JNICALL
Java_com_stt_opus_OpusDecoder_nativeDestroy(JNIEnv *env, jclass clazz, jlong handle) {
  (void) env;
  (void) clazz;
  if (handle != 0) opus_decoder_destroy((OpusDecoder *) (intptr_t) handle);
}

JNIEXPORT jint JNICALL
Java_com_stt_opus_OpusDecoder_nativeDecode(JNIEnv *env, jclass clazz, jlong handle,
                                             jbyteArray packet, jint packet_offset,
                                             jint packet_length, jshortArray pcm,
                                             jint pcm_offset, jint frame_size,
                                             jboolean decode_fec) {
  (void) clazz;
  if (handle == 0) {
    throw_exception(env, "java/lang/IllegalStateException", "Decoder is closed");
    return 0;
  }
  jbyte *packet_data = (*env)->GetByteArrayElements(env, packet, NULL);
  jshort *pcm_data = (*env)->GetShortArrayElements(env, pcm, NULL);
  if (packet_data == NULL || pcm_data == NULL) {
    if (packet_data != NULL) (*env)->ReleaseByteArrayElements(env, packet, packet_data, JNI_ABORT);
    return 0;
  }
  int result = opus_decode((OpusDecoder *) (intptr_t) handle,
                           (const unsigned char *) packet_data + packet_offset,
                           packet_length, pcm_data + pcm_offset, frame_size,
                           decode_fec ? 1 : 0);
  (*env)->ReleaseByteArrayElements(env, packet, packet_data, JNI_ABORT);
  (*env)->ReleaseShortArrayElements(env, pcm, pcm_data, 0);
  if (result < OPUS_OK) {
    throw_opus_error(env, result);
    return 0;
  }
  return result;
}

JNIEXPORT jint JNICALL
Java_com_stt_opus_OpusDecoder_nativeDecodePlc(JNIEnv *env, jclass clazz, jlong handle,
                                                jshortArray pcm, jint pcm_offset,
                                                jint frame_size) {
  (void) clazz;
  if (handle == 0) {
    throw_exception(env, "java/lang/IllegalStateException", "Decoder is closed");
    return 0;
  }
  jshort *pcm_data = (*env)->GetShortArrayElements(env, pcm, NULL);
  if (pcm_data == NULL) return 0;
  int result = opus_decode((OpusDecoder *) (intptr_t) handle, NULL, 0,
                           pcm_data + pcm_offset, frame_size, 0);
  (*env)->ReleaseShortArrayElements(env, pcm, pcm_data, 0);
  if (result < OPUS_OK) {
    throw_opus_error(env, result);
    return 0;
  }
  return result;
}

JNIEXPORT void JNICALL
Java_com_stt_opus_OpusDecoder_nativeResetState(JNIEnv *env, jclass clazz, jlong handle) {
  (void) clazz;
  if (handle == 0) {
    throw_exception(env, "java/lang/IllegalStateException", "Decoder is closed");
    return;
  }
  int result = opus_decoder_ctl((OpusDecoder *) (intptr_t) handle, OPUS_RESET_STATE);
  if (result != OPUS_OK) throw_opus_error(env, result);
}
