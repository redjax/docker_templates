#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR=$(realpath -m "${THIS_DIR}/..")
BACKUPS_DIR="${ROOT_DIR}/backups"

RETAIN=30
DRY_RUN=false

CWD=$(pwd)

function usage() {
  echo ""
  echo "Usage: ${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Print this menu and exit"
  echo "  --dry-run     Enable dry run mode, describe actions without taking them"
  echo "  --retain      (default: 30) Number of backups to retain"
  echo ""
}

function cleanup() {
  cd "${CWD}"
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --retain)
      RETAIN="$2"
      shift 2
      ;;
    *)
      echo "[ERROR] Invalid arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "${BACKUPS_DIR}" ]]; then
  echo "[ERROR] Could not find backups at path: ${BACKUPS_DIR}" >&2
  exit 1
fi

if [[ "${RETAIN}" -eq 0 ]]; then
  echo "[ERROR] --retain must be greater than 0" >&2
  exit 1
fi

if [[ "${DRY_RUN}" == "true" ]]; then
  echo "[DRY RUN] Dry run is enabled"
fi

echo ""
echo "Cleaning OpenGist backups"
echo "Retaining ${RETAIN} most recent backup(s)"

NUM_BACKUPS=$(find "${BACKUPS_DIR}" -maxdepth 1 -type f | wc -l)
echo "Found [${NUM_BACKUPS}] backup(s) in backups dir"

if [[ "${NUM_BACKUPS}" -le "${RETAIN}" ]]; then
  echo "Number of backups is less than retain value, skipping clean" >&2
  exit 0
fi

echo "Number of backups (${NUM_BACKUPS}) is greater than --retain value (${RETAIN}). Performing cleanup"

mapfile -t BACKUP_FILES < <(
  find "${BACKUPS_DIR}" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | awk '{print $2}'
)

NUM_TO_DELETE=$((NUM_BACKUPS - RETAIN))

for ((i=0; i<NUM_TO_DELETE; i++)); do
  FILE="${BACKUP_FILES[$i]}"
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[DRY RUN] Would delete oldest backup: ${FILE}"
  else
    echo "Deleting oldest backup: ${FILE}"
    rm -f -- "${FILE}"
  fi
done

echo "Cleanup complete"

