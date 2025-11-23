#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/..")

OUTPUT_FILE="${PROJECT_ROOT}/secret.key"

if [[ -f "$OUTPUT_FILE" ]]; then
  echo "[WARNING] Secret key file already exists at path: ${OUTPUT_FILE}."

  echo ""
  
  while true; do
    read -n 1 -r -p "Overwrite? (y/n): " _choice
    echo ""

    case $_choice in
      [Yy])
        echo "New key will overwrite the old one."
        break
        ;;
      [Nn])
        echo "Exiting."
        exit 2
        ;;
      *)
        echo "[ERROR] Invalid choice, please use 'y' or 'n'."
        ;;
    esac
  done
  
fi

## Generate a random 32-byte (256-bit) base64-encoded secret key and save to secret.key
echo "Generating secret key, saving to file: $OUTPUT_FILE"
head -c 32 /dev/urandom | base64 | tr -d '\n' > "${OUTPUT_FILE}"
