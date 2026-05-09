#!/bin/bash

if [[ $# != 1 ]];
then
    echo "e.g.: $0 [Release|Debug|Profile|ASAN]"
    exit 1
fi

SELF_DIR="$( cd "$( dirname "$0"   )" && pwd   )"
cd ~ || exit 1
SDK_PATH=${PROJECT_NAME}-linux
rm -rf "$SDK_PATH"
GIT_VERSION=$(git describe --tags --always --long --dirty=-dev)

if [[ $1 == 'Release' ]];
then
    export LDFLAGS+="-flto"
fi

echo -e "\nxxxbuild linux-x86_64"
"$SELF_DIR"/x86_64.sh "${PWD}/$SDK_PATH/x86_64" "$1" || exit 1
echo -e "\nxxxbuild linux-armeabi-v7a"
"$SELF_DIR"/armeabi-v7a.sh "${PWD}/$SDK_PATH/armeabi-v7a" "$1" || exit 1
echo -e "\nxxxbuild linux-arm64-v8a"
"$SELF_DIR"/arm64-v8a.sh "${PWD}/$SDK_PATH/arm64-v8a" "$1" || exit 1

mkdir -p "$SDK_PATH/include/sherpa-onnx/c-api"
cp "${PWD}/sherpa-onnx/c-api/c-api.h" "$SDK_PATH/include/sherpa-onnx/c-api/"

for arch_dir in "$SDK_PATH"/*; do
    if [ -d "$arch_dir/install" ]; then
        mkdir -p "$arch_dir/lib"
        cp "$arch_dir/install/lib/libsherpa-onnx-c-api.so" "$arch_dir/lib/" 2>/dev/null || true
        cp "$arch_dir/install/lib/libonnxruntime.so" "$arch_dir/lib/" 2>/dev/null || true
        chmod +x "$arch_dir/lib/"*.so 2>/dev/null || true
        rm -rf "$arch_dir/install"
    fi
done

echo "$GIT_VERSION" > "$SDK_PATH/VERSION"

tar -czf "${PROJECT_NAME}-linux-$1-${GIT_VERSION}.tar.gz" "$SDK_PATH"
rm -rf "$SDK_PATH"

echo -e "\n\n\nversion: $GIT_VERSION"
