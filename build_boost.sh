#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
if [ ! -d "$SCRIPT_DIR" ] || [ $SCRIPT_DIR = '.' ]; then SCRIPT_DIR="$PWD"; fi

BUILD_TYPES="$1 $2 $3 $4"
if [[ -z "${BUILD_TYPES// }" ]]; then
    echo "Build type not passed as a parameter. Building all ..."
    FIRST_BUILD_TYPE=Release
    REMAINING_BUILD_TYPES="Debug RelWithDebInfo MinSizeRel"
else
    FIRST_BUILD_TYPE="$1"
    REMAINING_BUILD_TYPES="$2 $3 $4"
fi

# need to set dummy values to load common vars from build_common
BUILD_TYPE=${FIRST_BUILD_TYPE}
ANDROID_ABI="x86_64"
source $SCRIPT_DIR/build_common.sh

if [ -d "Boost-for-Android" ]; then
    echo "Deleting source directory"
    rm -rf "Boost-for-Android"
fi

# Note: will build Release regardless of what BUILD_TYPE is
git clone https://github.com/eeg-digitizar/Boost-for-Android.git
cd Boost-for-Android
mkdir -p ${ANDROID_LIB_HOME}/${BUILD_TYPE}
./build-android.sh $NDK_HOME --target-version=$MINSDKVERSION --prefix=${ANDROID_LIB_HOME}/${BUILD_TYPE} --boost=1.78.0

# TODO: Find out how to actually build the other build variants (only copies release build right now)
for BUILD_TYPE in ${REMAINING_BUILD_TYPES}; do
    if [ -d ${ANDROID_LIB_HOME}/${BUILD_TYPE} ]; then
        echo "${ANDROID_LIB_HOME}/${BUILD_TYPE} exists already. Won't copy Boost output!"
        exit 1
    else
        cp -r ${ANDROID_LIB_HOME}/${FIRST_BUILD_TYPE} ${ANDROID_LIB_HOME}/${BUILD_TYPE} 
    fi
done

echo "Done building and installing Boost."
echo "Make sure to use cmake_policy(SET CMP0057 NEW) in CMake, or list operator in Boost's cmake won't work."
