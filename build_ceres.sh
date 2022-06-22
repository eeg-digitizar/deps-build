#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
if [ ! -d "$SCRIPT_DIR" ] || [ $SCRIPT_DIR = '.' ]; then SCRIPT_DIR="$PWD"; fi

if [ -d "ceres-solver-2.0.0" ]; then
    echo "Deleting source directory"
    rm -rf "ceres-solver-2.0.0"
fi

if [ -f "ceres-solver-2.0.0.tar.gz" ]; then
    echo "Skipping download of source tar"
else
    wget ceres-solver.org/ceres-solver-2.0.0.tar.gz
fi

tar -xzf ceres-solver-2.0.0.tar.gz
cd ceres-solver-2.0.0

for BUILD_TYPE in Debug Release RelWithDebInfo MinSizeRel; do
    for ANDROID_ABI in "armeabi-v7a" "arm64-v8a" "x86" "x86_64"; do

        echo "----------------------------------------------------"
        echo "ceres-solver-${BUILD_TYPE}-${ANDROID_ABI}"
        echo "----------------------------------------------------"

        BUILD_DIR="${PWD}/build"
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

        $CMAKE_HOME/cmake \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_TOOLCHAIN_FILE="${NDK_HOME}/build/cmake/android.toolchain.cmake" \
            -DANDROID_ABI=$ANDROID_ABI \
            -DANDROID_PLATFORM=android-$MINSDKVERSION \
            -DANDROID_STL=c++_shared \
            $NEON \
            -DEigen3_DIR="${INSTALL_PREFIX}/share/eigen3/cmake/" \
            -Dglog_DIR="${INSTALL_PREFIX}/lib/cmake/glog/" \
            -S . -B build &&
            $CMAKE_HOME/cmake --build build --config ${BUILD_TYPE} -j$(nproc) &&
            $CMAKE_HOME/cmake --build build --target install --config ${BUILD_TYPE} &&
            continue
        break 2 # last command did not get to continue
    done
done
