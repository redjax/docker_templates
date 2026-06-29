#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl &> /dev/null; then
    echo "[ERROR] curl is required but not installed. Please install curl and try again."
    exit 1
fi

## Defaults
ARCH="$(uname -m)"
PLATFORM="$(uname | tr '[:upper:]' '[:lower:]')"
CONCOURSE_HOST=""

# Normalize arch
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64 | arm64) ARCH="arm64" ;;
esac

usage() {
    echo "Usage: $0 -H <concourse-host> [-a <cpu-arch>] [-p <platform>]"
    echo
    echo "  -H, --host        Concourse host (e.g. http://localhost:8080) [required]"
    echo "  -a, --cpu-arch    CPU architecture (default: autodetect -> $ARCH)"
    echo "  -p, --platform    Platform (default: autodetect -> $PLATFORM)"
    echo "  -h, --help        Show this help"
    exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -H|--host)
            CONCOURSE_HOST="$2"
            shift 2
            ;;
        -a|--cpu-arch)
            ARCH="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$CONCOURSE_HOST" ]]; then
    echo "[ERROR] Concourse host is required."
    usage
fi

## Build download URL
FLY_DOWNLOAD_URL="${CONCOURSE_HOST}/api/v1/cli?arch=${ARCH}&platform=${PLATFORM}"

echo "Downloading fly CLI from: ${FLY_DOWNLOAD_URL}"
curl -sSL "$FLY_DOWNLOAD_URL" -o fly
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Download failed from $FLY_DOWNLOAD_URL"
    exit 1
fi

if [[ -s fly ]]; then
    chmod +x ./fly
    
    echo "Moving fly CLI binary to $HOME/.local/bin/fly (sudo may prompt)..."
    mv ./fly $HOME/.local/bin/fly
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to move fly binary to $HOME/.local/bin/fly"
        exit 1
    fi
    
    echo "Fly installed: $(fly --version)"
else
    echo "[ERROR] Download failed from $FLY_DOWNLOAD_URL"
    exit 1
fi
