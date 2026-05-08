#!/bin/bash

SYSTEM_NAME=Linux
SYSTEM_PROCESSOR=armv8-a

export AR=aarch64-linux-gnu-gcc-ar
export CC=aarch64-linux-gnu-gcc
export AS=$CC
export CXX=aarch64-linux-gnu-g++
export LD=aarch64-linux-gnu-ld
export RANLIB=aarch64-linux-gnu-ranlib
export STRIP=aarch64-linux-gnu-strip

mkdir -p "$1" || exit 1
BUILD_DIR=linux-arm64
rm -rf "$BUILD_DIR"

cmake -GNinja -B$BUILD_DIR \
    -DCMAKE_BUILD_TYPE="$2" \
    -DCMAKE_SYSTEM_NAME=$SYSTEM_NAME -DCMAKE_SYSTEM_PROCESSOR=$SYSTEM_PROCESSOR \
    -DCMAKE_TOOLCHAIN_FILE="$(pwd)/toolchains/aarch64-linux-gnu.toolchain.cmake" \
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
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX="$1/install" \
    "./" && \
cmake --build $BUILD_DIR && \
cmake --install $BUILD_DIR && \
rm -rf $BUILD_DIR || exit 1
