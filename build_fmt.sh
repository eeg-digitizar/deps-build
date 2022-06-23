#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
if [ ! -d "$SCRIPT_DIR" ] || [ $SCRIPT_DIR = '.' ]; then SCRIPT_DIR="$PWD"; fi

if [ -d "fmtlib" ]; then
    echo "Deleting source directory"
    rm -rf "fmtlib"
fi

if [ -f "fmtlib.tar.gz" ]; then
    echo "Skipping download of source tar"
else
    wget -O fmtlib.tar.gz https://github.com/fmtlib/fmt/archive/refs/tags/8.1.1.tar.gz
fi

mkdir fmtlib
tar -xzf fmtlib.tar.gz -C ./fmtlib --strip-components=1
cd fmtlib

BUILD_TYPES="$1 $2 $3 $4"
if [[ -z "${BUILD_TYPES// }" ]]; then
    echo "Build type not passed as a parameter. Building all ..."
    BUILD_TYPES="Debug Release RelWithDebInfo MinSizeRel"
fi

for BUILD_TYPE in ${BUILD_TYPES}; do
    for ANDROID_ABI in "armeabi-v7a" "arm64-v8a" "x86" "x86_64"; do

        echo "----------------------------------------------------"
        echo "fmtlib-${BUILD_TYPE}-${ANDROID_ABI}"
        echo "----------------------------------------------------"

        SOURCE_DIR="$PWD"
        BUILD_DIR="${SOURCE_DIR}/build"
        source $SCRIPT_DIR/build_common.sh

        if [ -d "$BUILD_DIR" ]; then
            echo "Deleting build directory"
            rm -rf "$BUILD_DIR"
        fi
        if [ "$ANDROID_ABI" = "armeabi-v7a" ]; then
            # always build this abi with neon optimization on
            NEON="-DANDROID_ARM_NEON=ON"
        else
            NEON="\\"
        fi

        $CMAKE_HOME/cmake \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_TOOLCHAIN_FILE="${NDK_HOME}/build/cmake/android.toolchain.cmake" \
            -DANDROID_ABI=$ANDROID_ABI \
            -DANDROID_PLATFORM=android-$MINSDKVERSION \
            -DANDROID_STL=c++_shared \
            -DFMT_TEST=0 \
            $NEON \
            -S . -B build &&
            $CMAKE_HOME/cmake --build build --config ${BUILD_TYPE} -j$(nproc) &&
            $CMAKE_HOME/cmake --build build --target install --config ${BUILD_TYPE} &&
            continue
        break 2 # last command did not get to continue
    done
done
