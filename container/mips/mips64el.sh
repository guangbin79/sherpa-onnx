#!/bin/bash

SYSTEM_NAME=Linux
SYSTEM_PROCESSOR=mips64

export AR=mips64el-linux-gnuabi64-ar
export CC=mips64el-linux-gnuabi64-gcc
export AS=mips64el-linux-gnuabi64-gcc
export CXX=mips64el-linux-gnuabi64-g++
export LD=mips64el-linux-gnuabi64-ld
export RANLIB=mips64el-linux-gnuabi64-ranlib
export STRIP=mips64el-linux-gnuabi64-strip

mkdir -p "$1" || exit 1
BUILD_DIR=linux-mips64el
rm -rf "$BUILD_DIR"

(cmake -GNinja -B$BUILD_DIR \
    -DCMAKE_BUILD_TYPE="$2" \
    -DCMAKE_SYSTEM_NAME=$SYSTEM_NAME -DCMAKE_SYSTEM_PROCESSOR=$SYSTEM_PROCESSOR \
    -DCROSSLIB_PATH=/opt/cross-library/linux/mips64el \
    -DCROSS_SHARED_PATH=linux/mips64el \
    "./" && \
    cmake --build $BUILD_DIR && \
    cp "$BUILD_DIR/${PROJECT_NAME}/${LIBRARY_PREFIX}${PROJECT_NAME}.so" "$1" && \
    chmod +x "$1/"*.so 2>/dev/null || true && \
    rm -rf $BUILD_DIR
    ) || exit 1
