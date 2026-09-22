#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
OVERLAYS_DIR="${PROJECT_ROOT}/overlays}"

DB_TYPE=""
OPERATION=""
FORCE="false"
DELETE="false"

usage() {
  cat <<EOF
Usage:
  ${0##*/} [OPTIONS]

Options:
  -h, --help                 Print this help menu.
  -t, --db-type    <string>  Tell MMDL container which database to use. Options: mysql, postgres[ql], sqlite, external.
  -o, --operation  <string>  Docker Compose operation. Options: up, down, restart.
  -r, --rm-data    <switch>  When present, add -v to docker compose down commands. Removes data in named Docker volumes.
  -f, --force      <switch>  When present, add --force-restart to commands.
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -t|--db-type)
      case $2 in
        [Mm][Yy][Ss][Qq][Ll])
          DB_TYPE="mysql"
          ;;
        [Pp][Oo][Ss][Tt][Gg][Rr][Ee][Ss]|[Pp][Oo][Ss][Tt][Gg][Rr][Ee][Ss][Qq][Ll])
          DB_TYPE="postgres"
          ;;
        [Ss][Qq][Ll][Ii][Tt][Ee])
          DB_TYPE="sqlite"
          ;;
        [Ee][Xx][Tt]|[Ee][Xx][Tt][Ee][Rr][Nn][Aa][Ll])
          DB_TYPE="external"
          ;;
        *)
          echo "[ERROR] Invalid db type: $2." >&2
          usage

          exit 1
          ;;
      esac

      shift 2
      ;;
    -o|--operation)
      case $2 in
        [Uu][Pp]|[Ss][Tt][Aa][Rr][Tt])
          OPERATION="up"
          ;;
        [Dd][Oo][Ww][Nn]|[Ss][Tt][Oo][Pp])
          OPERATION="down"
          ;;
        [Rr][Ee][Ss][Tt][Aa][Rr][Tt])
          OPERATION="restart"
          ;;
        *)
          echo "[ERROR] Invalid Docker operation: $2" >&2
          echo
          usage
          exit 1
          ;;
      esac
      shift 2
      ;;
    -f|--force)
      FORCE="true"
      shift
      ;;
    -r|--rm)
      DELETE="true"
      shift
      ;;
    *)
      echo "[ERROR] Invalid option: $1." >&2
      echo
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${DB_TYPE}" ]]; then
  echo "[ERROR] Missing --db-type" >&2
  echo
  usage
  exit 1
fi

if [[ -z "${OPERATION}" ]]; then
  echo "[ERROR] Missing --operation" >&2
  echo
  usage
  exit 1
fi

up_cmd=(docker compose)
down_cmd=(docker compose)

if [[ ! "${DB_TYPE}" == "external" ]]; then
  up_cmd+=(-f compose.yml -f "overlays/${DB_TYPE}.yml")
  down_cmd+=(-f compose.yml -f "overlays/${DB_TYPE}.yml")
else
  echo "Using external database. Make sure to set the correct environment variables."
fi

case "${OPERATION}" in
  up)
    up_cmd+=(up -d)
    ;;
  down)
    down_cmd+=(down)
    ;;
  restart)
    up_cmd+=(up -d)
    down_cmd+=(down)
    ;;
esac

if [[ "${FORCE}" == "true" ]]; then
  up_cmd+=(--force-recreate)
fi

if [[ "${DELETE}" == "true" ]]; then
  down_cmd+=(-v)
fi

cat <<EOF

[ Manage My Damn Life ]

  db: ${DB_TYPE}
  up: ${up_cmd[*]}
  down: ${down_cmd[*]}

EOF

if [[ "${OPERATION}" == "restart" ]]; then
  echo "Restarting Manage My Damn Life stack"

  if ! "${down_cmd[@]}" 2>&1; then
    echo "[ERROR] Failed stopping containers" >&2
    echo "Failed command:" >&2
    echo "  [x] ${down_cmd[*]}" >&2

    exit 1
  fi

  echo
  if ! "${up_cmd[@]}" 2>&1; then
    echo "[ERROR] Failed starting containers" >&2
    echo "Failed command:" >&2
    echo "  [x] ${up_cmd[*]}" >&2

    exit 1
  fi

elif [[ "${OPERATION}" == "up" ]]; then
  echo "Starting Manage My Damn Life containers"

  if ! "${up_cmd[@]}" 2>&1; then
    echo "[ERROR] Failed starting containers" >&2
    echo "Failed command:" >&2
    echo "  [x] ${up_cmd[*]}" >&2

    exit 1
  fi
else
  echo "Stopping Manage My Damn Life containers"
  if ! "${down_cmd[@]}" 2>&1; then
    echo "[ERROR] Failed stopping containers" >&2
    echo "Failed command:" >&2
    echo "  [x] ${down_cmd[*]}" >&2

    exit 1
  fi
fi
