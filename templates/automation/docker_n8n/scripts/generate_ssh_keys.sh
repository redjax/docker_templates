#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(realpath -m "${THIS_DIR}/..")"
OUTPUT_DIR="${REPO_ROOT}/ssh"

SSH_KEY_COMMENT=""
PRIVKEY_NAME="n8n_ed25519"
PUBKEY_NAME="${PRIVKEY_NAME}.pub"

PRIVKEY_PATH="${OUTPUT_DIR}/${PRIVKEY_NAME}"
PUBKEY_PATH="${OUTPUT_DIR}/${PUBKEY_NAME}"

echo ""
echo "[ n8n SSH keygen ]"
echo ""

[ ! -d "${OUTPUT_DIR}" ] && mkdir -p "${OUTPUT_DIR}"
[ $? -n 0 ] && echo "[ERROR] Failed creating output directory: ${OUTPUT_DIR}" && exit 1

echo "Generating key '${PRIVKEY_NAME}' at path ${OUTPUT_DIR}"
echo ""

ssh-keygen -t ed25519 -f "${PRIVKEY_PATH}" -N "" -C "${SSH_KEY_COMMENT}"
if [[ $? -ne 0 ]]; then
  echo ""
  echo "[ERROR] Failed to generate SSH key."
  exit
else
  echo ""
  echo "[SUCCESS] n8n SSH keys created."
  echo "  [-] Private key file: ${PRIVKEY_PATH}"
  echo "  [-] Public key file: ${PUBKEY_PATH}"
  echo ""
  echo "  [-] Public key contents:"
  cat "${PUBKEY_PATH}"
  echo ""
  
  exit 0
fi
