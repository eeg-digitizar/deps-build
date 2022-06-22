#!/bin/bash

if [ ! $BUILD_TYPE ] || [ ! $ANDROID_ABI ]; then
    echo "Error: BUILD_TYPE or ANDROID_ABI not set!"
    exit 1
fi

if [ $ANDROID_LIB_HOME ]; then
    echo "Installing to $ANDROID_LIB_HOME"
else
    # you can set ANDROID_LIB_HOME in ~/.bashrc
    echo "Error: ANDROID_LIB_HOME not set (Should point to the installation destination)"
    exit 1
fi

INSTALL_PREFIX="${ANDROID_LIB_HOME}/${BUILD_TYPE}/${ANDROID_ABI}/"
mkdir -p $INSTALL_PREFIX

MINSDKVERSION=24 # or freeimage will fail with "error: use of undeclared identifier 'ftello'; did you mean 'ftell'?"

if [ $NDK_HOME ] && [ -f $NDK_HOME/ndk-which ]; then
    echo "Android NDK found in $NDK_HOME"
else
    echo "Error: NDK_HOME should point to the Android NDK!"
    exit 1
fi

if [ $CMAKE_HOME ] && [ -f $CMAKE_HOME/cmake ]; then
    echo "CMake found in $CMAKE_HOME"
else
    echo "Error: CMAKE_HOME should point to the latest version of CMake!"
    exit 1
fi
