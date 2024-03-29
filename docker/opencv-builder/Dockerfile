# based on https://github.com/opencv-infrastructure/opencv-gha-dockerfile/blob/b905bff7c4f2b34053d44a431fa68fd68c0e600d/ubuntu-github-actions-android/Dockerfile

FROM ubuntu:20.04

ARG ANT_VERSION=1.10.12
ARG GRADLE_VERSION=5.6.4

# For 4.x
ARG ANDROID_BUILD_TOOLS_VERSION=28.0.3
ARG ANDROID_PLATFORM_VERSION=android-26
ARG NDK_VERSION=18.1.5063045
ARG CMAKE_VERSION=3.6.4111459
ARG ANDROID_TOOLS_ARCHIVE=sdk-tools-linux-3859397.zip

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    software-properties-common \
    build-essential ccache ninja-build \
    python3 python3-pip curl zip unzip file \
    openjdk-8-jdk openjdk-8-jre libncurses5 \
    && \
  add-apt-repository ppa:git-core/ppa && \
  apt-get install -y --no-install-recommends git && \
  rm -rf /var/lib/apt/lists/*

RUN \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
    && \
  rm -rf /var/lib/apt/lists/*

RUN curl -o /tmp/apache-ant-$ANT_VERSION-bin.zip https://downloads.apache.org/ant/binaries/apache-ant-$ANT_VERSION-bin.zip && \
    unzip -d /opt/ant /tmp/apache-ant-$ANT_VERSION-bin.zip && \
    rm /tmp/apache-ant-$ANT_VERSION-bin.zip

RUN curl -o /tmp/gradle-$GRADLE_VERSION-bin.zip https://downloads.gradle-dn.com/distributions/gradle-$GRADLE_VERSION-bin.zip && \
    unzip -d /opt/gradle /tmp/gradle-$GRADLE_VERSION-bin.zip && \
    rm /tmp/gradle-$GRADLE_VERSION-bin.zip

ENV ANDROID_HOME="/opt/android-sdk"

# find+chmod fixes permission issue for old tools package
RUN cd ~ && mkdir $ANDROID_HOME .android \
    && cd $ANDROID_HOME \
    && curl -o sdk.zip "https://dl.google.com/android/repository/$ANDROID_TOOLS_ARCHIVE" \
    && unzip sdk.zip \
    && rm sdk.zip \
    && find $ANDROID_HOME -executable -exec chmod a+rx {} \; \
    && echo "y\n" > /tmp/yes \
    && $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" < /tmp/yes

RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" < /tmp/yes
RUN $ANDROID_HOME/tools/bin/sdkmanager "platforms;$ANDROID_PLATFORM_VERSION" < /tmp/yes
RUN $ANDROID_HOME/tools/bin/sdkmanager "ndk;$NDK_VERSION" < /tmp/yes
RUN $ANDROID_HOME/tools/bin/sdkmanager "cmake;$CMAKE_VERSION" < /tmp/yes

RUN useradd ci -m -s /bin/bash -G users
USER ci

RUN git config --global --add safe.directory "*" && \
    git config --global user.email "opencv.ci" && \
    git config --global user.name "opencv.ci"

ENV ANT_HOME=/opt/ant/apache-ant-$ANT_VERSION
ENV GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2"
ENV ANDROID_HOME="/opt/android-sdk"
ENV ANDROID_SDK="/opt/android-sdk"
ENV ANDROID_NDK="/opt/android-sdk/ndk/$NDK_VERSION"
ENV ANDROID_NDK_HOME="/opt/android-sdk/ndk/$NDK_VERSION"
ENV PATH=$ANT_HOME/bin:$GRADLE_HOME/bin:$ANDROID_HOME/cmake/$CMAKE_VERSION/bin:$PATH

ENTRYPOINT bash
