#!/bin/bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAYS_DIR="${THIS_DIR}/overlays"
PG_OVERLAY="${OVERLAYS_DIR}/postgres.yml"
UI_OVERLAY="${OVERLAYS_DIR}/temporal-ui.yml"

START_STACK="false"
STOP_STACK="false"
RESTART_STACK="false"
FORCE="false"

cleanup() {
  cd "$original_dir" || exit
}
trap cleanup EXIT

if ! command -v docker compose --version &>/dev/null; then
  echo "[ERROR] Docker Compose is not installed."
  exit 1
fi

function print_help() {
    echo ""
    
    echo "[Temporal Docker Compose Stack Control]"
    echo " Controls the Temporal stack & its overlay containers."
    echo " Only works when all services are running on the localhost."

    echo ""
    
    echo " Usage: $0"
    echo "   -u|--up       Starts the full stack."
    echo "   -d|--down     Stops the full stack."
    echo "   -r|--restart  Restarts the full stack."

    echo ""
}

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
          -u|--up)
            START_STACK="true"
            shift
            ;;
          -d|--down)
            STOP_STACK="true"
            shift
            ;;
          -r|--restart)
            RESTART_STACK="true"
            shift
            ;;
          -f|--force)
            FORCE="true"
            shift
            ;;
          -h|--help)
            print_help
            exit 0
            ;;
          *)
            echo "Unknown option $1"
            exit 1
            ;;
        esac
    done            
}

parse_args "$@"

if [[ "$START_STACK" == "false" && "$STOP_STACK" == "false" && "$RESTART_STACK" == "false" ]]; then
  print_help
  exit 0
fi

cd "$THIS_DIR"

cmd=(docker compose -f compose.yml -f overlays/postgres.yml -f overlays/temporal-ui.yml)

if [[ "$START_STACK" == "true" ]]; then
  echo "Starting full Temporal stack"
  cmd+=(up -d)

  if [[ "$FORCE" == "true" ]]; then
    echo "  FORCE=true, containers will be recreated"
    cmd+=(--force-recreate)
  fi

elif [[ "$STOP_STACK" == "true" ]]; then
  echo "Stopping full Temporal stack"
  cmd+=(down --remove-orphans)
elif [[ "$RESTART_STACK" == "true" ]]; then
  echo "Restarting full Temporal stack"
  cmd+=(down --remove-orphans)
  cmd+=(up -d)
  if [[ "$FORCE" == "true" ]]; then
    cmd+=(--force-recreate)
  fi
fi

echo "Command:"
echo "  ${cmd[@]}"
echo ""

"${cmd[@]}"
if [[ $? -ne 0 ]]; then
  echo ""

  if [[ "$START_STACK" == "true" ]]; then
    echo "[ERROR] Temporal stack failed to start."
  elif [[ "$STOP_STACK" == "true" ]]; then
    echo "[ERROR] Temporal stack failed to stop."
  elif [[ "$RESTART_STACK" == "true" ]]; then
    echo "[ERROR] Temporal stack failed to restart."
  fi
  echo "[ERROR] Failed to start Temporal stack."
  exit $?
else
  echo ""
  if [[ "$START_STACK" == "true" ]]; then
    echo "Temporal stack started successfully."
  elif [[ "$STOP_STACK" == "true" ]]; then
    echo "Temporal stack stopped successfully."
  elif [[ "$RESTART_STACK" == "true" ]]; then
    echo "Temporal stack restarted successfully."
  fi

  exit 0
fi
