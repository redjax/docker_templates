#!/usr/bin/env bash
set -euo pipefail

TAG="mise-tools:alpine"
DOCKERFILE="./Dockerfile.alpine"
GITHUB_TOKEN_FILE="./github_token.txt"
DISABLE_CACHE=false

USE_GITHUB_TOKEN=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

function usage() {
  cat <<'EOF'
Usage:
  ./build.sh [options]

Options:
  --tag VALUE               Image tag (default: mise-tools:alpine)
  --dockerfile PATH         Dockerfile path (default: ./Dockerfile.alpine)
  --github-token-file PATH   GitHub token file path (default: ./github_token.txt)
  --no-cache                Build with a fresh cache
  -h, --help                Show this help
EOF
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
    --no-cache)
      DISABLE_CACHE=true
      shift
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

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Dockerfile not found at path: $DOCKERFILE" >&2
  exit 1
fi

DOCKERFILE="$(cd "$(dirname "$DOCKERFILE")" && pwd)/$(basename "$DOCKERFILE")"

SECRET_ARGS=()
if [[ -f "$GITHUB_TOKEN_FILE" ]]; then
  GITHUB_TOKEN_FILE="$(cd "$(dirname "$GITHUB_TOKEN_FILE")" && pwd)/$(basename "$GITHUB_TOKEN_FILE")"
  SECRET_ARGS=(--secret "id=github_token,src=$GITHUB_TOKEN_FILE")
  USE_GITHUB_TOKEN=true
  echo "Using GitHub token from: $GITHUB_TOKEN_FILE"
else
  echo "No GitHub token file found at: $GITHUB_TOKEN_FILE"
  echo "Building without GitHub token (may hit rate limits)"
fi

NO_CACHE_ARGS=()
if [[ "$DISABLE_CACHE" == true ]]; then
  NO_CACHE_ARGS=(--no-cache)
  echo "Building without cache"
fi

echo ""
echo "Building Alpine-based mise container '$TAG'"
echo ""

cd "${REPO_ROOT}"

if ! docker build \
  "${NO_CACHE_ARGS[@]}" \
  "${SECRET_ARGS[@]}" \
  -t "$TAG" \
  --file "$DOCKERFILE" \
  "$REPO_ROOT"
then
  echo "Failed to build the Docker image." >&2
  exit 1
fi

echo ""
echo "Build completed successfully for image: $TAG"
echo "Execute the container with:"
echo "  docker run -it --rm $TAG"
echo ""
