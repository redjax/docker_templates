#!/usr/bin/env bash
set -euo pipefail

## Defaults
TAG="tools:latest"
DOCKERFILE="Dockerfile"
PYTHON_VERSION="3.13"
UV_VERSION="0.9.18"
GITLEAKS_VERSION="8.18.1"
OSV_VERSION="1.5.0"
TERRAFORM_VERSION="1.9.8"
TERRAFORM_LS_VERSION="0.34.3"
TFSEC_VERSION="1.28.10"
TFLINT_VERSION="0.53.0"
GO_VERSION="1.25.5"

## Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag) TAG="$2"; shift 2 ;;
    --dockerfile) DOCKERFILE="$2"; shift 2 ;;
    --python-version) PYTHON_VERSION="$2"; shift 2 ;;
    --uv-version) UV_VERSION="$2"; shift 2 ;;
    --gitleaks-version) GITLEAKS_VERSION="$2"; shift 2 ;;
    --osv-version) OSV_VERSION="$2"; shift 2 ;;
    --terraform-version) TERRAFORM_VERSION="$2"; shift 2 ;;
    --terraform-ls-version) TERRAFORM_LS_VERSION="$2"; shift 2 ;;
    --tfsec-version) TFSEC_VERSION="$2"; shift 2 ;;
    --tflint-version) TFLINT_VERSION="$2"; shift 2 ;;
    --go-version) GO_VERSION="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

## Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Resolve Dockerfile path
if [[ "$DOCKERFILE" != /* ]]; then
  DOCKERFILE="$SCRIPT_DIR/$DOCKERFILE"
fi

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Dockerfile not found at path: $DOCKERFILE" >&2
  exit 1
fi

## Check docker
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not in PATH." >&2
  exit 1
fi

echo ""
echo "Building container '$TAG'"
echo "Dockerfile: $DOCKERFILE"
echo "Build context: $SCRIPT_DIR"
echo ""

## Build
if ! docker build \
  -t "$TAG" \
  -f "$DOCKERFILE" \
  --build-arg UV_VER="$UV_VERSION" \
  --build-arg PYTHON_VER="$PYTHON_VERSION" \
  --build-arg GITLEAKS_VER="$GITLEAKS_VERSION" \
  --build-arg OSV_VER="$OSV_VERSION" \
  --build-arg TERRAFORM_VER="$TERRAFORM_VERSION" \
  --build-arg TERRAFORM_LS_VER="$TERRAFORM_LS_VERSION" \
  --build-arg TFSEC_VER="$TFSEC_VERSION" \
  --build-arg TFLINT_VER="$TFLINT_VERSION" \
  --build-arg GO_VER="$GO_VERSION" \
  "$SCRIPT_DIR"
then
  echo "Docker build failed." >&2
  exit 1
fi

echo ""
echo "Build completed successfully for image: $TAG"
echo "Execute the container with:"
echo "  docker run -it --rm $TAG"
echo "Or mount current directory:"
echo "  docker run -it --rm -v \"$(pwd)\":/workspace $TAG"
echo ""
