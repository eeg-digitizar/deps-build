#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
if [ ! -d "$SCRIPT_DIR" ] || [ $SCRIPT_DIR = '.' ]; then SCRIPT_DIR="$PWD"; fi

# need to set dummy values to load common vars from build_common
BUILD_TYPE=Release
ANDROID_ABI="x86_64"
source $SCRIPT_DIR/build_common.sh

if [ -d "Boost-for-Android" ]; then
    echo "Deleting source directory"
    rm -rf "Boost-for-Android"
fi

git clone https://github.com/eeg-digitizar/Boost-for-Android.git
cd Boost-for-Android
mkdir -p ${ANDROID_LIB_HOME}/Release
./build-android.sh $NDK_HOME --target-version=$MINSDKVERSION --prefix=${ANDROID_LIB_HOME}/Release --boost=1.78.0

# TODO: Find out how to actually build the other build variants
if [ -d ${ANDROID_LIB_HOME}/Debug ]; then
    echo "${ANDROID_LIB_HOME}/Debug exists already. Won't copy Boost output!"
    exit 1
else
    cp -r ${ANDROID_LIB_HOME}/Release ${ANDROID_LIB_HOME}/Debug
fi
if [ -d ${ANDROID_LIB_HOME}/RelWithDebInfo ]; then
    echo "${ANDROID_LIB_HOME}/RelWithDebInfo exists already. Won't copy Boost output!"
    exit 1
else
    cp -r ${ANDROID_LIB_HOME}/Release ${ANDROID_LIB_HOME}/RelWithDebInfo
fi
if [ -d ${ANDROID_LIB_HOME}/MinSizeRel ]; then
    echo "${ANDROID_LIB_HOME}/MinSizeRel exists already. Won't copy Boost output!"
    exit 1
else
    cp -r ${ANDROID_LIB_HOME}/Release ${ANDROID_LIB_HOME}/MinSizeRel
fi

echo "Done building and installing Boost."
echo "Make sure to use cmake_policy(SET CMP0057 NEW) in CMake, or list operator in Boost's cmake won't work."
