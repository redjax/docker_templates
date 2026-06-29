#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
OUTPUT_DIR="${PROJECT_ROOT}/.ssh"
KEY_NAME="id_ed25519"

# echo "[DEBUG] THIS_DIR: ${THIS_DIR}"
# echo "[DEBUG] PROJECT_ROOT: ${PROJECT_ROOT}"
# echo "[DEBUG] OUTPUT_DIR: ${OUTPUT_DIR}"
# echo "[DEBUG] KEY_NAME: ${KEY_NAME}"

if ! command -v ssh-keygen &>/dev/null; then
  echo "[ERROR] ssh-keygen is not installed."
  exit 1
fi

function usage() {
  echo ""
  echo "Usage: ${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -d, --output-dir  Path to directory where key files will be saved. Example: ~/.ssh, ./ssh"
  echo "  -f, --key-file    Key filename. Default: id_ed25519"
  echo "  -h, --help  Print this help menu."
  echo ""
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--output-dir)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --output-dir provided, but no directory path given."
        usage
        exit 1
      fi

      OUTPUT_DIR="$2"
      shift 2
      ;;
    -f|--key-file)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --key-file provided, but no key filename given."
        usage
        exit 1
      fi

      KEY_NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Invalid arg: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$KEY_NAME" ]]; then
  echo "[ERROR] Missing key filename. Use -f/--key-filename [id_<algorithm>"
  usage
  exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  echo "[ERROR] Missing output directory. Use -d/--output-dir [/output/path]"
  usage
  exit 1
fi

KEY_PATH="${OUTPUT_DIR}/${KEY_NAME}"

## Create output dir if not exists
if [[ ! -d "$OUTPUT_DIR" ]]; then
  mkdir -p "${OUTPUT_DIR}"
fi

if [[ -f "${KEY_PATH}" ]]; then
  echo "[WARNING] Key already exists at path '${KEY_PATH}'"
  echo ""

  while true; do
    read -n 1 -r -p "Overwrite SSH key? (y/n)" choice
    echo ""

    case $choice in
      [Yy])
        break
        ;;
      [Nn])
        echo "Skipping SSH key generation."
        exit 2
        ;;
      *)
        echo "[ERROR] Invalid choice: $choice. Please use 'y' or 'n'."
        exit 1
        ;;
    esac
  done
fi

echo ""
echo "Generating soft-serve SSH keys."
echo "  Outputting to: ${OUTPUT_DIR}."
echo "  Keyfiles: "
echo "    private: ${KEY_PATH}"
echo "    public:  ${KEY_PATH}.pub"
echo ""

if ! ssh-keygen -t ed25519 -N "" -C "" -f "${KEY_PATH}"; then
  echo "[ERROR] Failed creating SSH keys."
  exit 1
else
  echo "[OK] Generated SSH keys at path ${KEY_PATH}/${KEY_NAME}.pub"
  exit 0
fi

