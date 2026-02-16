#!/usr/bin/env bash
set -euo pipefail

USER_OWNER="$USER"
GROUP_OWNER="$USER"

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath -m "$THIS_DIR/..")"
BACKUP_DIR="./backups"

CWD=$(pwd)

function cleanup() {
  cd "$CWD"
}
trap cleanup EXIT

function usage() {
  echo ""
  echo "Usage: ${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help         Print this help menu."
  echo "  -u, --user         Owning user name."
  echo "  -g, --group        Owning group name."
  echo "  -o, --backup-dir   Path where backups are stored."
  echo ""
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--user)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --user provided, but no username given." >&2
        usage
        exit 1
      fi

      USER_OWNER="$2"
      shift 2
      ;;
    -g|--group)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --group provided, but not group name given."  >&2
        usage
        exit 1
      fi

      GROUP_OWNER="$2"
      shift 2
      ;;
    -o|--backup-dir)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --backup-dir provided, but no directory path given." >&2
        usage
        exit 1
      fi

      BACKUP_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Invalid arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

cd "$PROJECT_ROOT"

echo ""
echo "Setting owner of backups in ${BACKUP_DIR} to ${USER_OWNER}:${GROUP_OWNER}"
echo ""

if ! chown -R $USER_OWNER:$GROUP_OWNER "${BACKUP_DIR}" >&2; then
  echo "[ERROR] Failed to set backups owner." >&2
  exit 1
fi
