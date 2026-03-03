#!/usr/bin/env bash
set -uo pipefail

if ! command -v curl &>/dev/null; then
  echo "[ERROR] curl is not installed."
  exit 1
fi

if ! command -v tar &>/dev/null; then
  echo "[ERROR] tar is not installed."
  exit 1
fi

INSTALL_DIR="/usr/local/bin"
INSTALL_NAME="soft"

## Create temp dir and cleanup
TMPDIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

## Detect OS, capitalize first letter only (match release naming)
OS="$(uname)"
case "$OS" in
  Linux|Darwin) ;;
  *) echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

## Detect ARCH as in release asset names
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

echo "Detected OS=$OS ARCH=$ARCH"

## Get latest release JSON
API_URL="https://api.github.com/repos/charmbracelet/soft-serve/releases/latest"
echo "Fetching latest release info"
json="$(curl -fsSL "$API_URL")"

## Extract tag_name (version)
TAG_NAME="$(echo "$json" | grep -oP '"tag_name":\s*"\K(.*?)(?=")')"
if [[ -z "$TAG_NAME" ]]; then
  echo "Could not find latest tag_name" >&2
  exit 1
fi
echo "Latest release: $TAG_NAME"

## Find asset URL for exact OS & ARCH match ending with .tar.gz
ASSET_URL="$(echo "$json" \
  | grep "browser_download_url" \
  | grep "${OS}_${ARCH}" \
  | grep '\.tar\.gz"' \
  | head -n1 \
  | sed -E 's/.*"(https:[^"]+)".*/\1/')"

if [[ -z "$ASSET_URL" ]]; then
  echo "Could not find matching asset for $OS $ARCH" >&2
  exit 1
fi
echo "Downloading asset: $ASSET_URL"

if [[ -z "$ASSET_URL" ]]; then
  echo "Could not find matching asset for $OS $ARCH" >&2
  exit 1
fi
echo "Downloading asset: $ASSET_URL"

ARCHIVE_PATH="$TMPDIR/soft-serve.tar.gz"
curl -fsSL -o "$ARCHIVE_PATH" "$ASSET_URL"

echo "Extracting archive"
tar -xzf "$ARCHIVE_PATH" -C "$TMPDIR"

SOFT_BIN="$(find "$TMPDIR" -type f -name 'soft' | head -n1)"
if [[ -z "$SOFT_BIN" ]]; then
  echo "Could not find soft binary after extraction" >&2
  exit 1
fi

echo "Installing to $INSTALL_DIR/$INSTALL_NAME"
sudo install -m 755 "$SOFT_BIN" "$INSTALL_DIR/$INSTALL_NAME"

echo "Installed soft CLI to $INSTALL_DIR/$INSTALL_NAME"

echo "Installed version:"
"$INSTALL_DIR/$INSTALL_NAME" --version || true
