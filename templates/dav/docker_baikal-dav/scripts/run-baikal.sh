#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
OVERLAYS_DIR="${PROJECT_ROOT}/overlays"
DIRECT_ACCESS_OVERLAY="${OVERLAYS_DIR}/direct.yml"
CADDY_ACCESS_OVERLAY="${OVERLAYS_DIR}/caddy.yml"

EXPOSE_DIRECT="false"
EXPOSE_CADDY="false"
DOCKER_OPERATION=

function usage() {
  cat <<EOF
Usage:
  ${0} [OPTIONS]

Options:
  -h, --help                Print this help menu.
  --direct                  Expose Baikal directly using the overlays/direct.yml layer.
  --caddy                   Expose Baikal behind Caddy reverse proxy.
  -o, --operation <string>  Docker operation (up, down, pull)

Operations:
  NOTE: You must include an exposure method with each of these commands (--caddy, --direct)

  up|start: Bring the compose stack up.
  down|stop: Bring the compose stack down.
  restart: Bring the compose stack down, then back up.
  pull|update: Pull container images and restart.

Examples:
  ./run-baikal.sh --direct -o up
  ./run-baikal.sh --caddy -o update
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    --direct)
      EXPOSE_DIRECT="true"
      shift
      ;;
    --caddy)
      EXPOSE_CADDY="true"
      shift
      ;;
    -o|--operation)
      case $2 in
        up|start)
          DOCKER_OPERATION="up"
          ;;
        down|stop)
          DOCKER_OPERATION="down"
          ;;
        restart)
          DOCKER_OPERATION="restart"
          ;;
        pull|update)
          DOCKER_OPERATION="update"
          ;;
      esac

      shift 2
      ;;
    *)
      echo "[ERROR] Invalid flag: ${1}" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "${EXPOSE_DIRECT}" == "false" ]] && [[ "${EXPOSE_CADDY}" == "false" ]]; then
  echo "[ERROR] You must pass an exposure method, either --direct or --caddy" >&2
  echo

  usage
  exit 1
fi

if [[ "${EXPOSE_DIRECT}" == "true" ]] && [[ "${EXPOSE_CADDY}" == "true" ]]; then
  echo "[ERROR] You cannot pass both --direct and --caddy. Choose 1 exposure method." >&2
  echo

  usage
  exit 1
fi

docker_cmd="docker compose -f compose.yml"

if [[ "${EXPOSE_DIRECT}" == "true" ]]; then
  docker_cmd="${docker_cmd} -f overlays/direct.yml"
elif [[ "${EXPOSE_CADDY}" == "true" ]]; then
  docker_cmd="${docker_cmd} -f overlays/caddy.yml"
fi

case "${DOCKER_OPERATION}" in
  up)
    docker_cmd="${docker_cmd} up -d"
    ;;
  down)
    docker_cmd="${docker_cmd} down"
    ;;
  restart)
    docker_cmd="${docker_cmd} down && ${docker_cmd} up -d"
    ;;
  pull)
    docker_cmd="${docker_cmd} pull"
    ;;
  *)
    echo "[ERROR] Invalid Docker operation: ${DOCKER_OPERATION}" >&2

    usage
    exit 1
    ;;
esac

echo
echo "Running Docker command:"
echo "${docker_cmd}"
echo

eval "${docker_cmd}"
