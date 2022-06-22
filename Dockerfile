FROM ubuntu:20.04

ENV ANDROID_HOME="/opt/android"
ENV PATH $PATH:$ANDROID_HOME/cmdline-tools/latest/bin

WORKDIR /tmp

# Install dependencies
# (see https://developer.android.com/studio/install#linux)
RUN dpkg --add-architecture i386 \
    && apt-get update -qq \
    && apt-get install -qq -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 > /dev/null \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y wget curl git unzip default-jre build-essential > /dev/null \
    && rm -rf /var/lib/apt/lists/*

# Install Android commandline tools
RUN wget --quiet "https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip" \
    && unzip -qq commandlinetools-linux-7583922_latest.zip \
    && yes | ./cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME 'cmdline-tools;latest' > /dev/null \
    && rm -Rf /tmp/*

# get more from `sdkmanager --list`
RUN echo "Installing Android SDK ..."
RUN yes | sdkmanager 'platforms;android-31' 'build-tools;33.0.0' > /dev/null

RUN echo "Installing Android NDK ..."
RUN yes | sdkmanager --install "ndk;24.0.8215888" "cmake;3.18.1" > /dev/null

ENV NDK_HOME=$ANDROID_HOME/ndk/24.0.8215888/
ENV CMAKE_HOME=$ANDROID_HOME/cmake/3.18.1/bin/