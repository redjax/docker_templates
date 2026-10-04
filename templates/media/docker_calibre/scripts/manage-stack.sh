#!/usr/bin/env bash
set -euo pipefail

###############################################################
# Script for managing my Calibre eBook stack                  #
#                                                             #
# This script is specific to the machine running my stack.    #
# I will update it as I add/remove containers I "always run." #
###############################################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD=$(pwd)
trap 'cd "$CWD"' EXIT

OPERATION=""
FORCE="false"
LOG_CONTAINER=""

usage() {
  cat <<EOF
Usage:
  ${0##*/} [OPTIONS]

Options:
  -h, --help                      Print this help menu.
  -o, --operation       <string>  The Compose operation to run.
                                    Options: [run|start|up], [down|stop], [restart], [update|upgrade]
  --force                         Add --force-recreate to Compose command.
  -n, --container-name  <string>  Pass a service container name defined in one of the .yml files to see that container's logs.
EOF
}

## Accepts a command as an array and executes it
run_cmd() {
  local -a _cmd=("$@")

  echo "[DEBUG] Command:"
  printf '  %q ' "${_cmd[@]}"
  echo

  if ! "${_cmd[@]}" 2>&1; then
    echo "[ERROR] Failed running command: ${_cmd[*]}" >&2
    return 1
  fi
}

## Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--operation)
      OPERATION="${2,,}"
      shift 2
      ;;
    --force)
      FORCE="true"
      shift
      ;;
    -n|--container-name)
      LOG_CONTAINER="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Invalid option: $1" >&2
      echo

      usage
      exit 1
      ;;
  esac
done

## Array of compose files in my 'default' stack
declare -a compose_files=(
  compose.yml
  overlays/backups.yml
  overlays/calibre-web.yml
  overlays/sftpgo.yml
)

cmd=(docker compose)
## The restart operation does both
restart_up_cmd=(docker compose)
restart_down_cmd=(docker compose)
pull_cmd=(docker compose)
log_cmd=(docker compose)

if [[ -z "${OPERATION}" ]]; then
  echo "[ERROR] Missing --operation" >&2
  echo

  usage
  exit 1
fi

for c in "${compose_files[@]}"; do
  if [[ ! -f "${c}" ]]; then
    echo "[ERROR] Could not find Compose file: $c" >&2
    exit 1
  fi

  cmd+=(-f "${c}")

  case "${OPERATION}" in
    restart|update|upgrade)
      restart_down_cmd+=(-f "${c}")
      restart_up_cmd+=(-f "${c}")
      pull_cmd+=(-f "${c}")
      ;;
    log|logs)
      log_cmd+=(-f "${c}")
      ;;
  esac
done

case "${OPERATION}" in
  run|start|up)
    cmd+=(up -d)

    if [[ "${FORCE}" == "true" ]]; then
      cmd+=(--force-recreate --remove-orphans)
    fi
    ;;
  down|stop)
    cmd+=(down)

    if [[ "${FORCE}" == "true" ]]; then
      cmd+=(--remove-orphans)
    fi
    ;;
  restart)
    restart_down_cmd+=(down)
    restart_up_cmd+=(up -d)

    if [[ "${FORCE}" == "true" ]]; then
      restart_down_cmd+=(--remove-orphans)
      restart_up_cmd+=(--force-recreate --remove-orphans)
    fi
    ;;
  update|upgrade)
    restart_down_cmd+=(down)
    restart_up_cmd+=(up -d)
    pull_cmd+=(pull)

    if [[ "${FORCE}" == "true" ]]; then
      restart_down_cmd+=(--remove-orphans)
      restart_up_cmd+=(--force-recreate --remove-orphans)
    fi
    ;;
  log|logs)
    if [[ -z "${LOG_CONTAINER}" ]]; then
      echo "[ERROR] Container name required for logs. Pass one with -n <container-name>" >&2
      echo

      usage
      exit 1
    fi

    log_cmd+=(logs -f "${LOG_CONTAINER}")
    ;;
  *)
    echo "[ERROR] Invalid operation: ${OPERATION}" >&2
    echo

    usage
    exit 1
    ;;
esac

echo

## Execute docker command
case "${OPERATION}" in
  run|start|up)
    run_cmd "${cmd[@]}"
    ;;
  down|stop)
    run_cmd "${cmd[@]}"
    ;;
  restart)
    run_cmd "${restart_down_cmd[@]}"

    echo "Pause..."
    sleep 2

    run_cmd "${restart_up_cmd[@]}"
    ;;
  update|upgrade)
    run_cmd "${pull_cmd[@]}"
    run_cmd "${restart_down_cmd[@]}"

    echo "Pause..."
    sleep 2

    run_cmd "${restart_up_cmd[@]}"
    ;;
  log|logs)
    run_cmd "${log_cmd[@]}"
    ;;
esac