#inspired by: 
# - https://github.com/mmozeiko/docker-unity3d
# - https://gitlab.com/gableroux/unity3d

#using Ubuntu "Focal"
FROM ubuntu:20.04

# See here for unity/linux versions
#https://forum.unity.com/threads/unity-on-linux-release-notes-and-known-issues.350256/page-2
ARG UNITY_SETUP=http://beta.unity3d.com/download/0af376155913/UnitySetup
ARG SHA1=eee2b8e41ecc2d0b9387064b422ada604a08c68b


ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "Updating packages before installing Unity"

RUN echo "Australia/Perth" > /etc/timezone && \
    apt-get update -qq && \
    apt-get install -qq -y \
    debconf \
    ffmpeg \
    freeglut3-dev \
    gconf-service \
    git \
    lib32gcc1 \
    lib32stdc++6 \
    libarchive13 \
    libasound2 \
    libc6 \
    libc6-i386 \
    libcairo2 \
    libcap2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libfreetype6 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libglu1-mesa \
    libglu1-mesa-dev \
    libgtk2.0-0 \
    libgtk3.0 \
    libnotify4 \
    libnspr4 \
    libnss3 \
    libpango1.0-0 \
    libpq5 \
    libsoup2.4-1 \
    libstdc++6 \
    libunwind-dev \
    libx11-6 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    locales \
    lsb-release \
    mesa-common-dev \
    npm \
    openssh-server \
    pulseaudio \
    wget \
    xdg-utils \
    xvfb \
    zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# To avoid annoying "perl: warning: Setting locale failed." errors,
# do not allow the client to pass custom locals, see:
# http://stackoverflow.com/a/2510548/15677
RUN sed -i 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config

ENV UNITY_INSTALL_LOCATION /opt/Unity
ARG UNITY_COMPONENTS=Unity,Windows-Mono,Mac,Mac-Mono,WebGL

RUN echo "Installing Unity to ${UNITY_INSTALL_LOCATION}"

# Download and install Unity.
RUN wget -nv ${UNITY_SETUP} -O UnitySetup && \
    #do sha1 check:
    if [ -n "${SHA1}" -a "${SHA1}" != "" ]; then \
        echo "${SHA1}  UnitySetup" | sha1sum --check -; \
    else \
        echo "no sha1 given, skipping checksum"; \
    fi && \
    #make the file executable
    # make executable
    chmod +x UnitySetup && \
    # agree with license
    echo y | \
    # install unity with required components
    ./UnitySetup \
        --unattended \
        --install-location=$UNITY_INSTALL_LOCATION \
        --verbose \
        --download-location=/tmp/unity \
        --components=$UNITY_COMPONENTS && \
    # remove setup & temp files
    rm UnitySetup && \
    rm -rf /tmp/unity && \
    rm -rf /root/.local/share/Trash/*
# Deleting OpenJDK, we're installing it elsewhere
RUN rm -rf /opt/Unity/Editor/Data/PlaybackEngines/AndroidPlayer/Tools/OpenJDK 

RUN echo "Finished installing Unity"
###################
## ANDROID SETUP ##
###################
# Android SDK versions
ARG ANDROID_NDK_VERSION=19.2.5345600
ARG ANDROID_BUILD_TOOLS_VERSION=29.0.3
ARG ANDROID_PLATFORM_VERSION=29
ARG ANDROID_CMD_LINE_TOOLS_VERSION=6858069

# Setup Android SDK/JDK Environment Variables
ENV ANDROID_INSTALL_LOCATION ${UNITY_INSTALL_LOCATION}/Editor/Data/PlaybackEngines/AndroidPlayer
ENV ANDROID_SDK_ROOT ${ANDROID_INSTALL_LOCATION}/SDK
ENV ANDROID_HOME ${ANDROID_SDK_ROOT}
ENV ANDROID_NDK_HOME ${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION}
ENV PATH=${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

RUN echo "Installing JAVA"
#Setup Java
# install openJDK 8
RUN apt-get update -qq \
#    && add-apt-repository ppa:openjdk-r/ppa \
    && apt-get install -qq -y --no-install-recommends \
        openjdk-8-jdk

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:${PATH}
ARG SDK_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_LINE_TOOLS_VERSION}_latest.zip"

RUN echo "Downloading and installing Android SDK tools ${ANDROID_CMD_LINE_TOOLS_VERSION}"
# Download Android SDK commandline tools
RUN export JAVA_HOME \
    && mkdir -p ${ANDROID_SDK_ROOT} \
    && chown -R 777 ${ANDROID_INSTALL_LOCATION}
RUN wget -q ${SDK_TOOLS_URL} -O android-sdk.zip
RUN unzip -q android-sdk.zip -d ${ANDROID_SDK_ROOT} \
    && rm -f android-sdk.zip \
    && ls -ahl ${ANDROID_SDK_ROOT}

ENV PATH=${ANDROID_SDK_ROOT}/cmdline-tools/bin:$PATH

RUN echo "Installing platform SDK tools and NDK:${ANDROID_NDK_VERSION}" \
# Install platform tools and NDK
    && yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
        "platform-tools" \
        "ndk;${ANDROID_NDK_VERSION}" \
        > /dev/null

RUN echo "Installing build tools ${ANDROID_BUILD_TOOLS_VERSION}" \
# Install specified build tools
    && yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        > /dev/null

RUN echo "Installing platform ${ANDROID_PLATFORM_VERSION}" \
# Install specified platform
    && yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
        "platforms;android-${ANDROID_PLATFORM_VERSION}" \
        > /dev/null \

# Accept licenses
    && yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses

RUN echo "Cleaning Up"
# Clean
RUN apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*


#So we can execute commands:
# https://stackoverflow.com/questions/59035543/how-to-execute-command-from-one-docker-container-to-another

#create unitybuild user
RUN useradd -m --no-log-init --system --uid 1000 unitybuild -s /bin/bash -g sudo -G root

#set the password to unitybuild
RUN echo 'unitybuild:unitybuild' | chpasswd

USER unitybuild
ADD unitybuild.sh /src/
#fix build tool line endings if cloned on windows machine
RUN sed $'s/\r$//' /src/unitybuild.sh > /src/unitybuildCorrect.sh \
&& mv /src/unitybuildCorrect.sh /src/untybuild.sh \
&& chmod +x /src/unitybuild.sh

RUN echo "Running Unity for licensing / cert creation"
#Certificates / licensing
RUN mkdir -p ~/.local/share/unity3d/Certificates/ && \
    mkdir -p ~/.local/share/unity3d/Unity/
ADD conf/CACerts.pem /home/unitybuild/.local/share/unity3d/Certificates/
ADD conf/asound.conf /etc/
RUN /opt/Unity/Editor/Unity -batchmode -quit -nographics -createManualActivationFile -logfile manualactivationfile.log /dev/stdout || :


USER root
#copy libraries to /src/opt/Unity/Editor/Data/Managed so they can be linked against
RUN mkdir -p /src/opt/Unity/Editor/Data/Managed
RUN cp -R /opt/Unity/Editor/Data/Managed /src/opt/Unity/Editor/Data/
RUN mkdir /run/sshd