#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TAG="aqua-tools:latest"
DOCKERFILE="$SCRIPT_DIR/Dockerfile"
GITHUB_TOKEN_FILE="$SCRIPT_DIR/github_token.txt"
PYTHON_VERSION="3.13"
AQUA_INSTALLER_VERSION="v4.0.4"
AQUA_VERSION="v2.55.3"

function usage() {
  cat <<'EOF'
Usage:
  ./build.sh [options]

Options:
  --tag VALUE                  Image tag (default: aqua-tools:latest)
  --dockerfile PATH            Dockerfile path (default: ./Dockerfile)
  --github-token-file PATH     GitHub token file path (default: ./github_token.txt)
  --python-version VALUE       Python version (default: 3.13)
  --aqua-installer-version V   Aqua installer version (default: v4.0.4)
  --aqua-version V             Aqua CLI version (default: v2.55.3)
  -h, --help                   Show this help
EOF
}

function resolve_path() {
  local path="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path"
  else
    local dir base
    dir="$(dirname "$path")"
    base="$(basename "$path")"
    cd "$dir" && printf '%s/%s\n' "$(pwd)" "$base"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --dockerfile)
      DOCKERFILE="$2"
      shift 2
      ;;
    --github-token-file)
      GITHUB_TOKEN_FILE="$2"
      shift 2
      ;;
    --python-version)
      PYTHON_VERSION="$2"
      shift 2
      ;;
    --aqua-installer-version)
      AQUA_INSTALLER_VERSION="$2"
      shift 2
      ;;
    --aqua-version)
      AQUA_VERSION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not available in the system PATH." >&2
  exit 1
fi

DOCKERFILE="$(resolve_path "$DOCKERFILE")"

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Dockerfile not found at path: $DOCKERFILE" >&2
  exit 1
fi

BUILD_ARGS=(
  --build-arg "PYTHON_VERSION=$PYTHON_VERSION"
  --build-arg "AQUA_INSTALLER_VERSION=$AQUA_INSTALLER_VERSION"
  --build-arg "AQUA_VERSION=$AQUA_VERSION"
)

SECRET_ARGS=()
if [[ -f "$GITHUB_TOKEN_FILE" ]]; then
  GITHUB_TOKEN_FILE="$(resolve_path "$GITHUB_TOKEN_FILE")"
  SECRET_ARGS=(--secret "id=github_token,src=$GITHUB_TOKEN_FILE")
  echo "Using GitHub token from: $GITHUB_TOKEN_FILE"
else
  echo "No GitHub token file found at: $GITHUB_TOKEN_FILE"
  echo "Building without GitHub token (may hit rate limits)"
fi

echo ""
echo "Building Aqua container '$TAG'"
echo "  Base: python:$PYTHON_VERSION-slim-bookworm"
echo "  Aqua Installer: $AQUA_INSTALLER_VERSION"
echo "  Aqua CLI: $AQUA_VERSION"
echo ""

if ! docker build \
  "${SECRET_ARGS[@]}" \
  "${BUILD_ARGS[@]}" \
  -t "$TAG" \
  -f "$DOCKERFILE" \
  "$REPO_ROOT"
then
  echo "Docker build failed." >&2
  exit 1
fi

echo ""
echo "Build completed successfully"
echo ""
echo "Run the container with:"
echo "  docker run -it --rm $TAG"
echo ""
echo "Or with a mounted workspace:"
echo "  docker run -it --rm -v \"$(pwd)\":/workspace $TAG"
echo ""
