#!/bin/bash

# Migration installer for RadBill
# This script stops legacy gonet services before running the standard installer.

set -e

# Stop and disable legacy services
LEGACY_SERVICES=(gonet-api gonet-acs gonet-radius gonet-worker)

for svc in "${LEGACY_SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^${svc}\.service"; then
        echo "Stopping legacy service: ${svc}"
        systemctl stop "${svc}" || true
        echo "Disabling legacy service: ${svc}"
        systemctl disable "${svc}" || true
    fi
	done

# Detect Architecture
ARCH=$(dpkg --print-architecture)
BASE_URL="https://github.com/radbill/radbill/releases/latest/download"

echo "Detected Architecture: $ARCH"

if [ "$ARCH" = "amd64" ]; then
    URL="$BASE_URL/installer-linux-amd64"
elif [ "$ARCH" = "arm64" ]; then
    URL="$BASE_URL/installer-linux-arm64"
else
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading installer..."
wget -q --show-progress "$URL" -O install.bin

if [ $? -ne 0 ]; then
    echo "Error: Failed to download installer. Please check your internet connection."
    exit 1
fi

chmod +x install.bin

echo "Running installer..."
if [ "$(id -u)" -eq 0 ]; then
    ./install.bin
else
    sudo ./install.bin
fi

# Cleanup
rm install.bin
