#!/bin/bash
set -e # exit on error

# ref: https://askubuntu.com/a/30157/8698
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

# ref: https://askubuntu.com/a/970898
# run commands without sudo privileges: sudo -u $real_user non-root-command
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

# OpenCV: https://docs.opencv.org/4.x/d7/d9f/tutorial_linux_install.html
echo "Building OpenCV"
apt-get update -qq && apt-get -qq -y install libgtk2.0-dev pkg-config unzip cmake build-essential > /dev/null
wget --quiet -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/4.5.5.zip
wget --quiet -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/4.5.5.zip
unzip -qq opencv.zip
unzip -qq opencv_contrib.zip
cmake -S opencv-4.5.5 \
      -B build_opencv \
      -DOPENCV_EXTRA_MODULES_PATH=opencv_contrib-4.5.5/modules/ \
      -DOPENCV_ENABLE_NONFREE=1 \
      -DCMAKE_INSTALL_PREFIX=/opt/opencv-4.5.5-desktop-sdk \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_JAVA=OFF \
      -DBUILD_FAT_JAVA_LIB=OFF \
      -DBUILD_opencv_python2=OFF \
      -DBUILD_opencv_python3=OFF > /dev/null
cmake --build build_opencv -j$(nproc) > /dev/null
cmake --install build_opencv > /dev/null

# fmt: https://fmt.dev/latest/usage.html?highlight=cmake#building-the-library
echo "Building libfmt"
wget --quiet -O fmtlib.tar.gz https://github.com/fmtlib/fmt/archive/refs/tags/8.1.1.tar.gz
tar -xzf fmtlib.tar.gz
cmake -S fmt-8.1.1 -B build_fmt -DFMT_TEST=OFF > /dev/null
cmake --build build_fmt -j$(nproc) > /dev/null
cmake --install build_fmt > /dev/null

# Ceres: http://ceres-solver.org/installation.html
echo "Building Ceres"
apt-get update -qq && apt-get install -qq -y libeigen3-dev \
    libsuitesparse-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libatlas-base-dev > /dev/null
wget --quiet ceres-solver.org/ceres-solver-2.0.0.tar.gz
tar -xzf ceres-solver-2.0.0.tar.gz
cmake -S ceres-solver-2.0.0 -B build_ceres -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF > /dev/null
cmake --build build_ceres -j$(nproc) > /dev/null
cmake --install build_ceres > /dev/null

# COLMAP: https://colmap.github.io/install.html
echo "Building COLMAP"
apt-get update -qq && apt-get install -qq -y libfreeimage-dev \
    libboost-all-dev \
    libmetis-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev > /dev/null
wget --quiet -O colmap-3.7.zip https://github.com/colmap/colmap/archive/refs/tags/3.7.zip
unzip -qq colmap-3.7.zip
cmake -S colmap-3.7 -B build_colmap -DCUDA_ENABLED=OFF -DGUI_ENABLED=OFF -DTESTS_ENABLED=OFF > /dev/null
cmake --build build_colmap -j$(nproc) > /dev/null
cmake --install build_colmap > /dev/null
    
# GoogleTest (optional): https://github.com/google/googletest
echo "Building googletest"
wget --quiet -O googletest.zip https://github.com/google/googletest/archive/refs/tags/release-1.11.0.zip
unzip -qq googletest.zip
cmake -S googletest-release-1.11.0 -B build_googletest > /dev/null
cmake --build build_googletest -j$(nproc) > /dev/null
cmake --install build_googletest > /dev/null