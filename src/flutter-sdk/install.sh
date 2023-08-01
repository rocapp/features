#!/usr/bin/env bash
# shellcheck disable=SC2039
# shellcheck disable=SC2155
set -e
# shellcheck disable=SC2034
DEBIAN_FRONTEND="noninteractive"
RELEASES_URL="https://storage.googleapis.com/flutter_infra_release/releases"
TMP_DIR="/tmp/flutter"
RELEASES_JSON="releases_linux.json"

# Install dependencies
apt update &&
  apt install -y --no-install-recommends \
    libgtk-3-dev \
    ca-certificates \
    bash \
    curl \
    file \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    jq \
    xz-utils \
    clang \
    cmake \
    ninja-build \
    pkg-config

# get google chrome
cd /tmp && 
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
  apt -f install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb &&
  rm google-chrome-stable_current_amd64.deb && 
  cd -

su - "$_REMOTE_USER"

# Get latest releases
mkdir -p "$PUB_CACHE"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
curl -O "$RELEASES_URL/$RELEASES_JSON"

# Download and extract Flutter SDK
HASH=$(jq ".current_release.$RELEASE" $RELEASES_JSON)
FLUTTER_ARCHIVE=$(jq -r ".releases[] | select(.hash==$HASH) | .archive" releases_linux.json)
curl -O "$RELEASES_URL/$FLUTTER_ARCHIVE" &&
  tar -xf "$TMP_DIR/$(basename "$FLUTTER_ARCHIVE")" -C "$(dirname "$FLUTTER_HOME")" &&
    chown --recursive "$_REMOTE_USER:$_REMOTE_USER" $FLUTTER_HOME &&
      chmod --recursive ug+rwx $FLUTTER_HOME &&
        git config --global --add safe.directory $FLUTTER_HOME

set +e
# Clean up
cd "~" && 
  rm -rf "$TMP_DIR" &&
    apt clean
set -e

# Verify installation
su - "$_REMOTE_USER"
flutter doctor
