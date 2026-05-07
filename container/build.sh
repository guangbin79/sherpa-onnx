#!/bin/bash

if [[ $# -lt 1 ]];
then
    echo "e.g.: $0 <android|linux|oh|windows|all> [Release|Debug|Profile]"
    echo "e.g.: $0 check"
    echo "e.g.: $0 verify [library_name]"
    exit 1
fi

SELF_DIR="$( cd "$( dirname "$0"   )" && pwd   )"
cd "${SELF_DIR}" || exit 1
BUILD_TYPE=Release
LIBRARY_NAME=""

if [[ $1 == 'verify' ]]; then
    if [[ $# == 2 ]]; then
        if [[ $2 == 'Release' || $2 == 'Debug' || $2 == 'Profile' || $2 == 'ASAN' ]]; then
            BUILD_TYPE=$2
        else
            LIBRARY_NAME=$2
        fi
    elif [[ $# == 3 ]]; then
        LIBRARY_NAME=$2
        BUILD_TYPE=$3
    fi
elif [[ $# == 2 ]]; then
    BUILD_TYPE=$2
fi

export PROJECT_NAME=sherpa-onnx

if [[ $1 == 'android' || $1 == 'all' ]]
then
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run -e HOME="$HOME" -e PROJECT_NAME=${PROJECT_NAME} -e LIBRARY_PREFIX="lib" sherpa-onnx-android_compiler "$HOME"/container/android/build.sh "$BUILD_TYPE" &
fi

if [[ $1 == 'linux' || $1 == 'all' ]]
then
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run -e HOME="$HOME" -e PROJECT_NAME=${PROJECT_NAME} -e LIBRARY_PREFIX="lib" sherpa-onnx-linux_compiler "$HOME"/container/linux/build.sh "$BUILD_TYPE" &
fi

if [[ $1 == 'oh' || $1 == 'all' ]]
then
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run -e HOME="$HOME" -e PROJECT_NAME=${PROJECT_NAME} -e LIBRARY_PREFIX="lib" sherpa-onnx-oh_compiler "$HOME"/container/oh/build.sh "$BUILD_TYPE" &
fi

if [[ $1 == 'mips' ]]
then
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run -e HOME="$HOME" -e PROJECT_NAME=${PROJECT_NAME} -e LIBRARY_PREFIX="lib" sherpa-onnx-mips_compiler "$HOME"/container/mips/build.sh "$BUILD_TYPE" &
fi

if [[ $1 == 'windows' || $1 == 'all' ]]
then
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run -e HOME="$HOME" -e PROJECT_NAME=${PROJECT_NAME} -e LIBRARY_PREFIX="lib" sherpa-onnx-windows_compiler "$HOME"/container/windows/build.sh "$BUILD_TYPE" &
fi

if [[ $1 == 'check' || $1 == 'all' ]]
then
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run -e HOME="$HOME" -e PROJECT_NAME=${PROJECT_NAME} -e LIBRARY_PREFIX="lib" sherpa-onnx-linux_checker "$HOME"/container/check "$BUILD_TYPE" &
fi

if [[ $1 == 'verify' ]]
then
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run -e HOME="$HOME" -e PROJECT_NAME=${PROJECT_NAME} -e LIBRARY_PREFIX="lib" sherpa-onnx-linux_checker "$HOME"/container/verify-cross-library-examples "$BUILD_TYPE" "$LIBRARY_NAME"
fi

wait

USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose down

if [[ $1 == 'all' ]]
then
    reset
fi
