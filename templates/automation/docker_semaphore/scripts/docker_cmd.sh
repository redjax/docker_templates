#!/usr/bin/env bash
set -uo pipefail

if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker is not installed."
  exit 1
fi

if ! command -v docker compose &>/dev/null; then
  echo "[ERROR] Docker Compose is not installed"
  exit 1
fi

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/..")

COMPOSE_FILE="${PROJECT_ROOT}/compose.yml"
OVERLAYS_DIR="${PROJECT_ROOT}/overlays"

MYSQL_OVERLAY="${OVERLAYS_DIR}/mysql.yml"
POSTGRES_OVERLAY="${OVERLAYS_DIR}/postgres.yml"

DRY_RUN="false"
RECREATE="false"
USE_DB=""
DB_OVERLAY=""
SVC=""
OPERATION="start"

function usage() {
  echo ""
  echo "Usage: ${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run                             Enable dry run mode. Instead of taking actions, \
describe the action that would have been taken."
  echo "  -r, --recreate, -f, --force-recreate  Recreate containers when starting them."
  echo "  -o, --operation                       The Docker Compose operation to run. \
Options: up/start, down/stop, logs <service-name>"
  echo "  --db                                  The database to use. \
Options: mysql, postgres"
  echo "  -h, --help                            Print this help menu"
  echo ""
}

function parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run)
        DRY_RUN="true"
        shift
        ;;
      -r|--recreate|-f|--force-recreate)
        RECREATE="true"
        shift
        ;;
      -o|--operation)
        if [[ -z "$2" ]]; then
          echo "[ERROR] --operation provided, but no Docker Compose operation given"
        fi

        case "$2" in
          start|up)
            OPERATION="start"

            shift 2
            ;;
          restart)
            OPERATION="restart"

            shift 2
            ;;
          stop|down)
            OPERATION="stop"

            shift 2
            ;;
          log|logs)
            OPERATION="logs"
            SVC="$3"

            shift 3
            ;;
        esac

        ;;
      --db)
        if [[ -z "$2" ]]; then
          echo "[ERROR] --db provided, but no database type given."
          
          usage
          exit 1
        fi

        case "${2,,}" in
          mysql)
            USE_DB="mysql"
            DB_OVERLAY="${MYSQL_OVERLAY}"

            shift 2
            ;;
          postgres)
            USE_DB="postgres"
            DB_OVERLAY="${POSTGRES_OVERLAY}"

            shift 2
            ;;
        esac
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
}

function main() {
  local CMD

  parse_args "${@}"

  echo "[ Semaphore ]"
  echo "  Operation: ${OPERATION}"
  echo "  Database: ${USE_DB}"

  case "${OPERATION}" in
    start)
      CMD=(docker compose -f "${COMPOSE_FILE}" -f "${DB_OVERLAY}" up -d)

      if [[ "${RECREATE}" == "true" ]]; then
        CMD+=(--force-recreate)
      fi
      ;;
    stop)
      CMD=(docker compose -f "${COMPOSE_FILE}" -f "${DB_OVERLAY}" down)
      ;;
    restart)
      CMD=(docker compose -f "${COMPOSE_FILE}" -f "${DB_OVERLAY}" down)
      ;;
    logs)
      CMD=(docker compose -f "${COMPOSE_FILE}" -f "${DB_OVERLAY}" logs -f "${SVC}")
      ;;
    *)
      echo "[ERROR] Invalid/unsupported operation: ${OPERATION}"
      
      usage
      exit 1
      ;;
  esac

  echo ""
  echo "Running command: ${CMD[*]}"
  echo ""

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] Would run command: ${CMD[@]}"
    exit 0
  else
    if ! "${CMD[@]}"; then
      echo "[ERROR] Failed running Docker command."
      exit 1
    else
      if [[ "${OPERATION}" == "restart" ]]; then
        echo "Restarting containers"
        CMD=(docker compose -f "${COMPOSE_FILE}" -f "${DB_OVERLAY}" up -d)
        if ! "${CMD[@]}"; then
          echo "[ERROR] Failed restarting containers"

          exit 1
        fi
      fi
    fi
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
