#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="latest"
WORKDIR=""
COMMAND=""
VOLUMES=()

## Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --volume|-v)
      VOLUMES+=("$2")
      shift 2
      ;;
    --command|-c)
      COMMAND="$2"
      shift 2
      ;;
    --image-tag|-t)
      IMAGE_TAG="$2"
      shift 2
      ;;
    --workdir|-w)
      WORKDIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

## Check docker
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not in PATH." >&2
  exit 1
fi

IMAGE_NAME="tools:${IMAGE_TAG}"

## Check if image exists locally
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "Warning: Image '$IMAGE_NAME' not found locally."
  echo "You may need to build it first:"
  echo "  ./build.sh"
  echo ""
  read -rp "Continue anyway and let Docker try to pull it? (y/n): " response
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
  fi
fi

## Build docker args
DOCKER_ARGS=(run -it --rm)

## Volumes
if [[ ${#VOLUMES[@]} -gt 0 ]]; then
  echo "Volume mounts:"
  for vol in "${VOLUMES[@]}"; do
    echo "  - $vol"
    DOCKER_ARGS+=(-v "$vol")
  done
fi

## Workdir
if [[ -n "$WORKDIR" ]]; then
  echo "Working directory: $WORKDIR"
  DOCKER_ARGS+=(-w "$WORKDIR")
fi

DOCKER_ARGS+=("$IMAGE_NAME")

## Run command or drop user into interactive shell
if [[ -n "$COMMAND" ]]; then
  echo "Executing command: $COMMAND"
  DOCKER_ARGS+=(/bin/sh -c "$COMMAND")
else
  echo "Starting interactive shell"
fi

## Show command
echo ""
echo "Docker command:"
printf 'docker'
printf ' %q' "${DOCKER_ARGS[@]}"
echo ""
echo ""

## Execute
if ! docker "${DOCKER_ARGS[@]}"; then
  exit_code=$?
  echo "Docker command failed with exit code $exit_code" >&2
  exit "$exit_code"
fi
