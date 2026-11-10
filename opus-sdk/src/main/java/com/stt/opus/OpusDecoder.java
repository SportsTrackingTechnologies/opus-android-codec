package com.stt.opus;

/** Stateful wrapper around an Opus decoder. Instances must be closed when no longer used. */
public final class OpusDecoder implements AutoCloseable {
    static {
        System.loadLibrary("opus_jni");
    }

    private long handle;
    private final int channels;

    public OpusDecoder(int sampleRate, int channels) {
        if (channels != 1 && channels != 2) {
            throw new IllegalArgumentException("channels must be 1 or 2");
        }
        this.channels = channels;
        this.handle = nativeCreate(sampleRate, channels);
    }

    /**
     * Decodes one complete Opus packet and returns the number of PCM samples per channel.
     *
     * @deprecated Use the offset/length overload when reusing packet or PCM buffers.
     */
    @Deprecated
    public synchronized int decode(byte[] packet, short[] pcm, int maxFrameSize, boolean decodeFec) {
        return decode(packet, 0, packet.length, pcm, 0, maxFrameSize, decodeFec);
    }

    /**
     * Decodes a range of one Opus packet into a PCM buffer range.
     *
     * @return number of PCM samples written per channel
     */
    public synchronized int decode(
            byte[] packet, int packetOffset, int packetLength,
            short[] pcm, int pcmOffset, int frameSize, boolean decodeFec) {
        requireOpen();
        requireRange(packet.length, packetOffset, packetLength, "packet");
        if (packetLength == 0) throw new IllegalArgumentException("packetLength must be greater than 0");
        requirePcmRange(pcm, pcmOffset, frameSize);
        return nativeDecode(handle, packet, packetOffset, packetLength, pcm, pcmOffset,
                frameSize, decodeFec);
    }

    /**
     * Generates packet-loss concealment PCM for one missing packet.
     *
     * @return number of PCM samples written per channel
     */
    public synchronized int decodePlc(short[] pcm, int pcmOffset, int frameSize) {
        requireOpen();
        requirePcmRange(pcm, pcmOffset, frameSize);
        return nativeDecodePlc(handle, pcm, pcmOffset, frameSize);
    }

    /** Resets decoder history so this instance can be reused for a new audio session. */
    public synchronized void resetState() {
        requireOpen();
        nativeResetState(handle);
    }

    @Override
    public synchronized void close() {
        if (handle != 0) {
            nativeDestroy(handle);
            handle = 0;
        }
    }

    private void requireOpen() {
        if (handle == 0) throw new IllegalStateException("Decoder is closed");
    }

    private void requirePcmRange(short[] pcm, int pcmOffset, int frameSize) {
        if (frameSize <= 0) throw new IllegalArgumentException("frameSize must be greater than 0");
        if (frameSize > Integer.MAX_VALUE / channels) {
            throw new IllegalArgumentException("frameSize is too large");
        }
        requireRange(pcm.length, pcmOffset, frameSize * channels, "pcm");
    }

    private static void requireRange(int arrayLength, int offset, int length, String name) {
        if (offset < 0 || length < 0 || offset > arrayLength - length) {
            throw new IllegalArgumentException(name + " offset/length is outside its array");
        }
    }

    private static native long nativeCreate(int sampleRate, int channels);
    private static native void nativeDestroy(long handle);
    private static native int nativeDecode(long handle, byte[] packet, int packetOffset,
                                           int packetLength, short[] pcm, int pcmOffset,
                                           int frameSize, boolean decodeFec);
    private static native int nativeDecodePlc(long handle, short[] pcm, int pcmOffset,
                                              int frameSize);
    private static native void nativeResetState(long handle);
}
