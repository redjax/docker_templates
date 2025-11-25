#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/..")
CONFIG_DIR="${PROJECT_ROOT}/config"

if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker is not installed."
  exit 1
fi

if ! command -v docker compose &>/dev/null; then
  echo "[ERROR] Docker compose is not installed."
  exit 1
fi

if ! command -v curl &>/dev/null; then
  echo "[ERROR] curl is not installed."
  exit 1
fi

if ! command -v tar &>/dev/null; then
  echo "[ERROR] tar is not installed."
  exit 1
fi

## -----------------------------------------------------------

## .env setup
if [[ ! -f "${PROJECT_ROOT}/.env" ]]; then
  echo "Copying .env.example -> .env"
  cp .env.example .env
else
  echo "Found Docker Compose .env file at ${PROJECT_ROOT}/.env"
fi

## SSH setup

## Check if directory exists
if [[ -d "${PROJECT_ROOT}/.ssh" ]]; then
  ## Check if directory contains any files other than .gitkeep
  shopt -s nullglob
  files=("${PROJECT_ROOT}/.ssh/"*)
  shopt -u nullglob

  ## Filter out .gitkeep
  non_gitkeep_files=()
  for f in "${files[@]}"; do
    if [[ "$(basename "$f")" != ".gitkeep" ]]; then
      non_gitkeep_files+=("$f")
    fi
  done

  if [[ ${#non_gitkeep_files[@]} -eq 0 ]]; then
    echo "SSH directory exists but does not have any keys. Running SSH setup."
    source "${PROJECT_ROOT}/scripts/generate-ssh-keys.sh"
    if [[ $? -ne 0 ]]; then
      echo "[ERROR] Failed setting up SSH keys."
      exit 1
    fi
  else
    echo "Found SSH keys in path: ${PROJECT_ROOT}/.ssh"
  fi
else
  echo "SSH directory does not exist. Running SSH setup."
  source "${PROJECT_ROOT}/scripts/generate-ssh-keys.sh"
  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed setting up SSH keys."
    exit 1
  fi
fi

## Copy soft-serve config
if [[ ! -f "${CONFIG_DIR}/soft-serve.yml" ]]; then
  echo "Copying ${CONFIG_DIR}/examples/soft-serve.yml -> ${CONFIG_DIR}/soft-serve.yml"
  cp "${CONFIG_DIR}/examples/soft-serve.yml" "${CONFIG_DIR}/soft-serve.yml"
else
  echo "Soft-serve config file found at ${CONFIG_DIR}/soft-serve.yml"
fi

echo ""
echo "Setup complete."
