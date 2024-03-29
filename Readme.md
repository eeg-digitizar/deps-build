# DigitizAR dependencies
This repository contains scripts and instructions to build the DigitizAR dependencies. 

## Build for Android
The dependencies required to build the Android application can be downloaded from the release section (you will need to unzip them before use):
- OpenCV library with contrib modules (`OpenCV4Android.zip`)
- Other dependencies with desired build configuration (`Libraries-*.zip`), e.g. `Libraries-Debug.zip` if you want to build a debug version of the app.

You can also crosscompile the dependencies (except for OpenCV) inside a Docker Container:
1. Build the docker image:
    ```sh
    docker build -t ghcr.io/eeg-digitizar/deps-builder:main - < Dockerfile
    ```
   Alternatively, you can pull it from the GitHub Container Registry:
    ```sh
    docker pull ghcr.io/eeg-digitizar/deps-builder:main
    ```
2. Create the ouput directory (the built libraries will be installed here) and run the container 
    ```sh
    export ANDROID_LIB_HOME=~/Libraries # modify this
    mkdir -p $ANDROID_LIB_HOME
    docker run -it -w /build_in -v "$(pwd):/build_in" -v "$ANDROID_LIB_HOME:/build_out" ghcr.io/eeg-digitizar/deps-builder:main
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

If you want to build OpenCV with the contrib modules yourself, you can adapt the CI buildscript `.github/workflows/opencv-android.yml`. 

## Build for PC
Build and install the libraries if you want to run the DigitizAR pipeline on your PC (e.g. for development):
```sh
mkdir temp && cd temp
sudo ../build_all_for_pc.sh
cd .. && sudo rm -rf temp
```
This will download the dependencies, build and install them. Note: The script was developed for Ubuntu 20.04.
