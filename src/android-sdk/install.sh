#!/usr/bin/env bash
# shellcheck disable=SC2039
set -e

LATEST="9477386"
URL="https://dl.google.com/android/repository"
# shellcheck disable=SC2027
ARCHIVE="commandlinetools-linux-"$LATEST"_latest.zip"
FOLDER="cmdline-tools"

# Install Dependencies
DEBIAN_FRONTEND="noninteractive" apt update && 
    apt install --no-install-recommends -y openjdk-11-jdk-headless unzip wget &&
        apt clean

# install -d -m 0755 -o "$_REMOTE_USER" -g "$_REMOTE_USER" "$ANDROID_HOME/cmdline-tools"

# Create the folder for the Android SDK
mkdir -p "$ANDROID_HOME/$FOLDER" 
    chown -R "$_REMOTE_USER:$_REMOTE_USER" "$ANDROID_HOME"

# Swap to the user that will be running the Android SDK
su - "$_REMOTE_USER"

# Download and extract the latest Android SDK command line tools
wget -q "$URL/$ARCHIVE" 
    unzip -q "$ARCHIVE" 
    rm "$ARCHIVE" 
    mv "$FOLDER" "$ANDROID_HOME/$FOLDER/latest" 
    rm -rf "$FOLDER"

PACKAGES=("platform-tools" "patcher;v4")
if [[ $PLATFORMS != "none" ]]; then
    PACKAGES+=("platforms;android-$PLATFORMS")
fi

if [[ ${BUILD-TOOLS} != "none" ]]; then
    PACKAGES+=("build-tools;${BUILD-TOOLS}")
fi

# append android cmdline-tools to path
PATH=$PATH:$ANDROID_HOME/$FOLDER/latest/bin

sdkmanager --install "${PACKAGES[@]}"
# sdkmanager --install "platforms;android-30"
# sdkmanager --install "build-tools;30.0.2"
# sdkmanager --install "extras;android;m2repository"
# sdkmanager --install "extras;google;m2repository"
