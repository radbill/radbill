#!/bin/bash

# Detect Architecture
ARCH=$(dpkg --print-architecture)
BASE_URL="https://github.com/radbill/radbill/releases/latest/download"

echo "Detected Architecture: $ARCH"

if [ "$ARCH" = "amd64" ]; then
    URL="$BASE_URL/updater-linux-amd64"
elif [ "$ARCH" = "arm64" ]; then
    URL="$BASE_URL/updater-linux-arm64"
else
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading updater..."
wget -q --show-progress "$URL" -O update.bin

if [ $? -ne 0 ]; then
    echo "Error: Failed to download updater. Please check your internet connection."
    exit 1
fi

chmod +x update.bin

echo "Running updater..."
sudo ./update.bin

# Cleanup
rm update.bin
