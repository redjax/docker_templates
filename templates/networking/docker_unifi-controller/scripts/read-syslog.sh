#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD=$(pwd)
trap 'cd -- "$CWD"' EXIT

LOG_FILE="all-remote.log"
TAIL_LINES="200"

function usage() {
  cat <<EOF
Usage:
  ${0} [OPTIONS]

Options:
  -h, --help                 Print this help menu
  -l, --log-file   <string>  Name of log file in container at /var/log/\$LOG_FILE. Default is 'all-remote.log'. Use 'unifi.log' to see only Unifi logs.
                             To see all tail-able logs, run the ./scripts/list-log-files.sh script.
  -n, --tail-lines <int>     Number of log lines to tail (default: 200)
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit 0
    ;;
  -l | --log-file)
    LOG_FILE="${2}"
    shift 2
    ;;
  -n | --tail-lines)
    TAIL_LINES="${2}"
    shift 2
    ;;
  *)
    echo "[ERROR] Invalid option: $1" >&2
    usage
    exit 1
    ;;
  esac
done

echo "Tailing logs for /var/log/${LOG_FILE}"
echo

docker compose exec -it rsyslog-collector tail -n "${TAIL_LINES}" -f "/var/log/${LOG_FILE}"
