#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
if [ ! -d "$SCRIPT_DIR" ] || [ $SCRIPT_DIR = '.' ]; then SCRIPT_DIR="$PWD"; fi

if [ -d "eigen-3.4.0" ]; then
    echo "Deleting source directory"
    rm -rf "eigen-3.4.0"
fi

if [ -f "eigen-3.4.0.tar" ]; then
    echo "Skipping download of source tar"
else
    wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar
fi

tar -xvf eigen-3.4.0.tar
cd eigen-3.4.0

BUILD_TYPES="$1 $2 $3 $4"
if [[ -z "${BUILD_TYPES// }" ]]; then
    echo "Build type not passed as a parameter. Building all ..."
    BUILD_TYPES="Debug Release RelWithDebInfo MinSizeRel"
fi

for BUILD_TYPE in ${BUILD_TYPES}; do
    for ANDROID_ABI in "armeabi-v7a" "arm64-v8a" "x86" "x86_64"; do

        SOURCE_DIR="${PWD}"
        BUILD_DIR="${SOURCE_DIR}/build"
        source $SCRIPT_DIR/build_common.sh

        if [ -d "$BUILD_DIR" ]; then
            echo "Deleting build directory"
            rm -rf "$BUILD_DIR"
        fi
        if [ "$ANDROID_ABI" = "armeabi-v7a" ]; then
            NEON="-DANDROID_ARM_NEON=ON"
        else
            NEON="\\"
        fi

        # use normal cmake (fortran of ndk broken)
        $CMAKE_HOME/cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
            -DANDROID_STL=c++_shared \
            $NEON \
            -S . -B build &&
            $CMAKE_HOME/cmake --build build -j$(nproc) &&
            $CMAKE_HOME/cmake --build build --target install &&
            continue
        break 2 # last command did not get to continue
    done
done
