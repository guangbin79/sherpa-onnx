#!/bin/bash

mkdir -p "$1" || exit 1
BUILD_DIR=android-armv7
rm -rf "$BUILD_DIR"

# Download onnxruntime for Android
onnxruntime_version=1.24.3
ANDROID_ABI_NAME=armeabi-v7a

if [ ! -f $onnxruntime_version/jni/$ANDROID_ABI_NAME/libonnxruntime.so ]; then
    mkdir -p $onnxruntime_version
    pushd $onnxruntime_version
    python3 -c "
import urllib.request
import zipfile
import os

url = 'https://github.com/csukuangfj/onnxruntime-libs/releases/download/v${onnxruntime_version}/onnxruntime-android-${onnxruntime_version}.zip'
zip_path = 'onnxruntime-android-${onnxruntime_version}.zip'
print(f'Downloading {url}...')
urllib.request.urlretrieve(url, zip_path)
print(f'Extracting {zip_path}...')
with zipfile.ZipFile(zip_path, 'r') as z:
    z.extractall('.')
os.remove(zip_path)
print('Done')
"
    popd
fi

export SHERPA_ONNXRUNTIME_LIB_DIR=$PWD/$onnxruntime_version/jni/$ANDROID_ABI_NAME/
export SHERPA_ONNXRUNTIME_INCLUDE_DIR=$PWD/$onnxruntime_version/headers/

echo "SHERPA_ONNXRUNTIME_LIB_DIR: $SHERPA_ONNXRUNTIME_LIB_DIR"
echo "SHERPA_ONNXRUNTIME_INCLUDE_DIR: $SHERPA_ONNXRUNTIME_INCLUDE_DIR"

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
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
    -DCMAKE_BUILD_TYPE="$2" \
    -DCMAKE_ANDROID_NDK="$ANDROID_NDK_HOME" \
    -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
    -DANDROID_NDK="$ANDROID_NDK_HOME" \
    -DANDROID_ABI=armeabi-v7a \
    -DANDROID_PLATFORM=android-21 \
    -DANDROID_STL=c++_static \
    -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG" \
    -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG" \
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE="-O3 -DNDEBUG" \
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE="-O3 -DNDEBUG" \
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
    -DSHERPA_ONNX_ESPEAK_NG_LINK_UCD_WHOLE_ARCHIVE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX="$1/install" \
    "./" && \
cmake --build $BUILD_DIR && \
cmake --install $BUILD_DIR && \
(cp -fv $onnxruntime_version/jni/$ANDROID_ABI_NAME/libonnxruntime.so "$1/install/lib" 2>/dev/null || true) && \
(chmod +x "$1/install/lib/"libonnxruntime.so 2>/dev/null || true) && \
rm -rf $BUILD_DIR || exit 1
