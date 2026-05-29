#!/usr/bin/env bash
set -euo pipefail

TAG="terraform-dev:latest"
DOCKERFILE="./Dockerfile"
TERRAFORM_VERSION="1.9.8"
TERRAFORM_LS_VERSION="0.34.3"
TFSEC_VERSION="1.28.10"
TFLINT_VERSION="0.53.0"

function usage() {
  cat <<'EOF'
Usage:
  ./build.sh [options]

Options:
  --tag VALUE                 Image tag (default: terraform-dev:latest)
  --dockerfile PATH          Dockerfile path (default: ./Dockerfile)
  --terraform-version VALUE   Terraform version (default: 1.9.8)
  --terraform-ls-version VALUE Terraform language server version (default: 0.34.3)
  --tfsec-version VALUE      TFSec version (default: 1.28.10)
  --tflint-version VALUE     TFLint version (default: 0.53.0)
  -h, --help                 Show this help
EOF
}

## Parse args
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
    --terraform-version)
      TERRAFORM_VERSION="$2"
      shift 2
      ;;
    --terraform-ls-version)
      TERRAFORM_LS_VERSION="$2"
      shift 2
      ;;
    --tfsec-version)
      TFSEC_VERSION="$2"
      shift 2
      ;;
    --tflint-version)
      TFLINT_VERSION="$2"
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

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Dockerfile not found at path: $DOCKERFILE" >&2
  exit 1
fi

DOCKERFILE="$(cd "$(dirname "$DOCKERFILE")" && pwd)/$(basename "$DOCKERFILE")"

echo ""
echo "Building container '$TAG' with Dockerfile at path '$DOCKERFILE'"
echo ""

if ! docker build \
  -t "$TAG" \
  --file "$DOCKERFILE" \
  --build-arg TERRAFORM_VER="$TERRAFORM_VERSION" \
  --build-arg TERRAFORM_LS_VER="$TERRAFORM_LS_VERSION" \
  --build-arg TFSEC_VER="$TFSEC_VERSION" \
  --build-arg TFLINT_VER="$TFLINT_VERSION" \
  .
then
  echo "Failed to build the Docker image." >&2
  exit 1
fi

echo ""
echo "Build completed successfully for image: $TAG"
echo "Execute the container with:"
echo "  docker run -it --rm $TAG"
echo "Or, if you want to mount the current directory in the container:"
echo "  docker run -it --rm -v \"$(pwd)\":/workspace $TAG"
echo ""
