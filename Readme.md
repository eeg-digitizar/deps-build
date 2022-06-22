# DigitizAR dependencies
This repository contains scripts and instructions to build the DigitizAR dependencies. 

## Build for Android
The libraries required to build the Android application can be crosscompiled inside a Docker Container:
1. Build the docker image:
    ```sh
    docker build -t lib-builder - < Dockerfile
    ```
2. Create the ouput directory (the built libraries will be installed here) and run the container 
    ```sh
    export ANDROID_LIB_HOME=~/Libraries # modify this
    mkdir -p $ANDROID_LIB_HOME
    docker run -it -w /build_in -v "$(pwd):/build_in" -v "$ANDROID_LIB_HOME:/build_out" lib-builder
    ```
3. Inside the container build the libraries
    ```sh
    export ANDROID_LIB_HOME=/build_out \
        && ./build_boost.sh \
        && ./build_fmt.sh \
        && ./build_eigen.sh \
        && ./build_freeimage.sh \
        && ./build_glog.sh \
        && ./build_libyuv.sh \
        && ./build_ceres.sh \
        && ./build_colmap.sh
    ```
4. Set `ANDROID_LIB_HOME` in your `~/.bashrc`, e.g.:
    ```sh
    ANDROID_LIB_HOME=~/Libraries
    ```
   In your own projects you can now prepend `ANDROID_LIB_HOME` to CMake's [`CMAKE_FIND_ROOT_PATH`](https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_ROOT_PATH.html#variable:CMAKE_FIND_ROOT_PATH) to use the libraries with the [`find_package()`](https://cmake.org/cmake/help/latest/command/find_package.html#command:find_package) command (use in [*config mode / with full signature*](https://cmake.org/cmake/help/latest/command/find_package.html#id6)).

## Build for PC
Build and install the libraries if you want to run the DigitizAR pipeline on your PC (e.g. for development):
```sh
mkdir temp && cd temp
sudo ../build_all_for_pc.sh
cd .. && rm -rf temp
```
This will download the dependencies, build and install them. Note: The script was developed for Ubuntu 20.04.