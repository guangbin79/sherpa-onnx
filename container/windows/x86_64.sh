#!/bin/bash

SYSTEM_NAME=Windows
SYSTEM_PROCESSOR=x86_64

export AR=x86_64-w64-mingw32-gcc-ar
export CC=x86_64-w64-mingw32-gcc
export AS=$CC
export CXX=x86_64-w64-mingw32-g++
export RC=x86_64-w64-mingw32-windres
export LD=x86_64-w64-mingw32-ld
export RANLIB=x86_64-w64-mingw32-ranlib
export STRIP=x86_64-w64-mingw32-strip

mkdir -p "$1" || exit 1
BUILD_DIR=windows-x86_64
rm -rf "$BUILD_DIR"

SELF_DIR="$( cd "$( dirname "$0"   )" && pwd   )"

CACHED_DEPS="/home/guangbin/build-deps/_deps"
FETCHCONTENT_OVERRIDES=""
for dep in kaldi_native_fbank kissfft kaldi_decoder kaldifst openfst eigen simple_sentencepiece json espeak_ng piper_phonemize; do
    src_dir="$CACHED_DEPS/${dep}-src"
    if [ -d "$src_dir" ]; then
        upper_dep=$(echo "$dep" | tr '[:lower:]' '[:upper:]')
        FETCHCONTENT_OVERRIDES="$FETCHCONTENT_OVERRIDES -DFETCHCONTENT_SOURCE_DIR_${upper_dep}=$src_dir"
    fi
done

cmake -GNinja -B$BUILD_DIR \
    -DCMAKE_TOOLCHAIN_FILE="${SELF_DIR}/mingw-w64-x86_64.cmake" \
    -DCMAKE_BUILD_TYPE="$2" \
    -DCMAKE_SYSTEM_NAME=$SYSTEM_NAME -DCMAKE_SYSTEM_PROCESSOR=$SYSTEM_PROCESSOR \
    $FETCHCONTENT_OVERRIDES \
    -DBUILD_PIPER_PHONMIZE_EXE=OFF \
    -DBUILD_PIPER_PHONMIZE_TESTS=OFF \
    -DBUILD_ESPEAK_NG_EXE=OFF \
    -DBUILD_ESPEAK_NG_TESTS=OFF \
    -DSHERPA_ONNX_ENABLE_TESTS=OFF \
    -DSHERPA_ONNX_ENABLE_PYTHON=OFF \
    -DSHERPA_ONNX_ENABLE_CHECK=OFF \
    -DSHERPA_ONNX_ENABLE_PORTAUDIO=OFF \
    -DSHERPA_ONNX_ENABLE_JNI=OFF \
    -DSHERPA_ONNX_ENABLE_C_API=ON \
    -DSHERPA_ONNX_ENABLE_WEBSOCKET=OFF \
    -DSHERPA_ONNX_ENABLE_BINARY=OFF \
    -DSHERPA_ONNX_ENABLE_TTS=ON \
    -DSHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=OFF \
    -DSHERPA_ONNX_BUILD_C_API_EXAMPLES=ON \
    -DCMAKE_INSTALL_PREFIX="$1/install" \
    "./" && \
cmake --build $BUILD_DIR && \
cmake --install $BUILD_DIR && \
rm -rf $BUILD_DIR || exit 1
