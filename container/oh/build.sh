#!/bin/bash

if [[ $# != 1 ]];
then
    echo "e.g.: $0 [Release|Debug|Profile|ASAN]"
    exit 1
fi

SELF_DIR="$( cd "$( dirname "$0"   )" && pwd   )"
cd ~ || exit 1
SDK_PATH=${PROJECT_NAME}-oh
rm -rf "$SDK_PATH"
GIT_VERSION=$(git describe --tags --always --long --dirty=-dev)

if [[ $1 == 'Release' ]];
then
    export LDFLAGS+="-flto"
fi

echo -e "\nxxxbuild oh-arm64-v8a"
"$SELF_DIR"/oh-arm64-v8a.sh "${PWD}/$SDK_PATH/arm64-v8a" "$1" || exit 1
echo -e "\nxxxbuild oh-armeabi-v7a"
"$SELF_DIR"/oh-armeabi-v7a.sh "${PWD}/$SDK_PATH/armeabi-v7a" "$1" || exit 1
echo -e "\nxxxbuild oh-x86_64"
"$SELF_DIR"/oh-x86_64.sh "${PWD}/$SDK_PATH/x86_64" "$1" || exit 1

mkdir -p "$SDK_PATH/include"
cp -r "${PWD}/sherpa-onnx/c-api" "$SDK_PATH/include/" 2>/dev/null || true
cp -r "${PWD}/sherpa-onnx/cxx-api" "$SDK_PATH/include/" 2>/dev/null || true
find "${PWD}" -name "*.h" -path "*/sherpa-onnx/*" -exec cp {} "$SDK_PATH/include/" \; 2>/dev/null || true

echo "$GIT_VERSION" > "$SDK_PATH/VERSION"

tar -czf "${PROJECT_NAME}-oh-$1-${GIT_VERSION}.tar.gz" "$SDK_PATH"
rm -rf "$SDK_PATH"

echo -e "\n\n\nversion: $GIT_VERSION"
