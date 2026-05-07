#!/bin/bash

SYSTEM_NAME=Linux
SYSTEM_PROCESSOR=armv7-a

OHNATIVE=/opt/command-line-tools/sdk/default/openharmony/native
export PATH=${OHNATIVE}/llvm/bin:$PATH

export AR=llvm-ar
export CC=armv7-unknown-linux-ohos-clang
export AS=$CC
export CXX=armv7-unknown-linux-ohos-clang++
export LD=lld
export RANLIB=llvm-ranlib
export STRIP=llvm-strip

mkdir -p "$1" || exit 1
BUILD_DIR=oh-armv7
rm -rf "$BUILD_DIR"

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
    -DCMAKE_BUILD_TYPE="$2" \
    -DCMAKE_SYSTEM_NAME=$SYSTEM_NAME -DCMAKE_SYSTEM_PROCESSOR=arm \
    -DCMAKE_C_COMPILER_TARGET=arm-linux-ohos -DCMAKE_CXX_COMPILER_TARGET=arm-linux-ohos \
    -DCMAKE_SYSROOT=$OHNATIVE/sysroot \
    -DCMAKE_CXX_FLAGS="-mfloat-abi=hard" \
    -DCMAKE_C_FLAGS="-mfloat-abi=hard" \
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
