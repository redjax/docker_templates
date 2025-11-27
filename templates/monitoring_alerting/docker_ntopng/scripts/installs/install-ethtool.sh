#!/usr/bin/env bash
set -uo pipefail

echo "Detecting OS and installing ethtool"

## Check if ethtool is already installed
if command -v ethtool &>/dev/null; then
    echo "ethtool is already installed."
    exit 0
fi

## Detect package manager
if command -v apt-get &>/dev/null; then
    echo "Debian/Ubuntu detected. Installing via apt"
    sudo apt-get update
    sudo apt-get install -y ethtool

elif command -v dnf &>/dev/null; then
    echo "Fedora/RHEL detected. Installing via dnf"
    sudo dnf install -y ethtool

elif command -v yum &>/dev/null; then
    echo "RHEL/CentOS detected. Installing via yum"
    sudo yum install -y ethtool

elif command -v pacman &>/dev/null; then
    echo "Arch Linux detected. Installing via pacman"
    sudo pacman -Sy --noconfirm ethtool

elif command -v apk &>/dev/null; then
    echo "Alpine Linux detected. Installing via apk"
    sudo apk add --no-cache ethtool

else
    echo "Unsupported OS or package manager. Please install ethtool manually."
    exit 1
fi

## Verify installation
if [[ -f /usr/loca/bin/ethtool ]]; then
    echo "ethtool installed successfully"
    echo "  Run with: sudo ethtool "
else
    echo "ethtool installation failed"
    exit 1
fi
