#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker compose >&/dev/null; then
  echo "[ERROR] docker compose is not installed" >&2
  exit 1
fi

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGH_ROOT=$(realpath -m "${THIS_DIR}/..")

CWD=$(pwd); trap 'cd "$CWD"' EXIT
MAIN_COMPOSE_FILE="${AGH_ROOT}/compose.yml"
UNBOUND_COMPOSE_FILE="${AGH_ROOT}/overlays/unbound.yml"

PULL="false"
RECREATE="false"
DRY_RUN="false"

function usage() {
  cat <<EOF
Usage: ${0} [OPTIONS]

Options:
  -h, --help          Print this help menu
  -p, -u, --pull      Pull new images
  -r, -f, --recreate  Recreate containers with --force-recreate
  --dry-run           Describe actions instead of taking them
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -u|-p|--pull)
      PULL="true"
      shift
      ;;
    -f|-r|--recreate)
      RECREATE="true"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    *)
      echo "[ERROR] Invalid arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

cd "${AGH_ROOT}"

CMD="docker compose -f ${MAIN_COMPOSE_FILE} -f ${UNBOUND_COMPOSE_FILE}"

if [[ "${RECREATE}" == "true" ]] && [[ "${PULL}" == "true" ]]; then
  CMD_1="${CMD} pull"
  CMD_2="${CMD} up -d --force-recreate"

  CMD="${CMD_1} && ${CMD_2}"
elif [[ "${RECREATE}" == "true" ]]; then
  CMD="${CMD} up -d --force-recreate"
elif [[ "${PULL}" == "true" ]]; then
  CMD="${CMD} pull"
else
  CMD="${CMD} up -d"
fi

if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY RUN] Would run command:"
  echo "  ${CMD}"
  echo
else
  echo "Running command:"
  echo "  ${CMD}"
  echo

  if ! eval "${CMD}" 2>&1; then
    echo "[ERROR] Docker Compose command failed" >&2
    exit 1
  fi
fi
