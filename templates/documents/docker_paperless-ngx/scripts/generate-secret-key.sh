#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT=$(realpath -m "${THIS_DIR}/..")

secret_key_file="${REPO_ROOT}/secret_key"

if [[ ! -f "${secret_key_file}" ]]; then
    echo ""
    echo "Generating secret key."
    echo "Add the secret to the docker-compose.env file"
    echo ""

    openssl rand -base64 64 >> "${secret_key_file}"
  elif [[ -f "${secret_key_file}" ]]; then
    echo ""
    echo "Secret key file exists."
    echo "Open the file and copy the key (getting rid of the newline) into your .env,"
    echo "i.e. PAPERLESS_SECRET_KEY=<your new secret>"
    echo ""
  else
    echo ""
    echo "Unknown error"
    echo ""
  fi