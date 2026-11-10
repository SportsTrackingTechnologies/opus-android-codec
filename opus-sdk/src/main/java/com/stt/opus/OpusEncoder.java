package com.stt.opus;

/** Stateful wrapper around an Opus encoder. Instances must be closed when no longer used. */
public final class OpusEncoder implements AutoCloseable {
    public static final int APPLICATION_VOIP = 2048;
    public static final int APPLICATION_AUDIO = 2049;
    public static final int APPLICATION_RESTRICTED_LOWDELAY = 2051;

    static {
        System.loadLibrary("opus_jni");
    }

    private long handle;
    private final int channels;

    public OpusEncoder(int sampleRate, int channels, int application) {
        if (channels != 1 && channels != 2) {
            throw new IllegalArgumentException("channels must be 1 or 2");
        }
        this.channels = channels;
        this.handle = nativeCreate(sampleRate, channels, application);
    }

    /** Encodes exactly {@code frameSize * channels} PCM samples and returns packet byte count. */
    public synchronized int encode(short[] pcm, int frameSize, byte[] packet) {
        requireOpen();
        if (frameSize <= 0 || pcm.length != frameSize * channels) {
            throw new IllegalArgumentException("pcm length must equal frameSize * channels");
        }
        if (packet.length == 0) {
            throw new IllegalArgumentException("packet must not be empty");
        }
        return nativeEncode(handle, pcm, frameSize, packet);
    }

    public synchronized void setBitrate(int bitsPerSecond) {
        requireOpen();
        nativeSetBitrate(handle, bitsPerSecond);
    }

    @Override
    public synchronized void close() {
        if (handle != 0) {
            nativeDestroy(handle);
            handle = 0;
        }
    }

    private void requireOpen() {
        if (handle == 0) throw new IllegalStateException("Encoder is closed");
    }

    private static native long nativeCreate(int sampleRate, int channels, int application);
    private static native void nativeDestroy(long handle);
    private static native int nativeEncode(long handle, short[] pcm, int frameSize, byte[] packet);
    private static native void nativeSetBitrate(long handle, int bitsPerSecond);
}
