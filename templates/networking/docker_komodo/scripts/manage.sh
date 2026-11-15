#!/usr/bin/env bash
set -Eeuo pipefail

# Resolve the project root relative to this script.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

COMPOSE_FILES=(-f compose.yml)
SERVICES=()
OPERATION=""
FORCE=false
FULL=false
REMAINING=()

usage() {
  cat <<'EOF'
Usage: ./scripts/manage.sh [OPTIONS] [CONTAINER]

Options:
  -f, --force              Force recreation of containers
      --full               Run against the full stack
  -s, --service SERVICE    Select a service/overlay (repeatable)
  -o, --operation OP       Operation to perform
  -h, --help               Show this help

Services:
  core       Komodo Core (includes MongoDB overlay)
  periphery  Komodo Periphery
  mongodb    MongoDB
  caddy      Caddy reverse proxy

Operations:
  up         Start the selected stack
  down       Stop and remove selected containers
  restart    Restart the stack or a specific container
  update     Pull images, bring the stack down, then start it
  pull       Pull images
  ps         Show service status
  logs       Follow logs

Examples:
  ./scripts/manage.sh --full -o up
  ./scripts/manage.sh -s core -o up
  ./scripts/manage.sh -s caddy -o up
  ./scripts/manage.sh -s core -s caddy -o up
  ./scripts/manage.sh --full -f -o up
  ./scripts/manage.sh --full -o restart
  ./scripts/manage.sh --full -o restart core
  ./scripts/manage.sh --full -o update
  ./scripts/manage.sh -s mongodb -o logs

Use --full to operate on the complete stack. If no service is
selected and --full is not specified, the script exits without
running Docker Compose.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

# Parse options.
while (($#)); do
  case "$1" in
    -f|--force)
      FORCE=true
      shift
      ;;
    --full)
      FULL=true
      shift
      ;;
    -s|--service)
      (($# >= 2)) || die "$1 requires a service name"
      SERVICES+=("$2")
      shift 2
      ;;
    --service=*)
      SERVICES+=("${1#*=}")
      shift
      ;;
    -o|--operation)
      (($# >= 2)) || die "$1 requires an operation"
      [[ -z "$OPERATION" ]] || die "Specify --operation only once"
      OPERATION="$2"
      shift 2
      ;;
    --operation=*)
      [[ -z "$OPERATION" ]] || die "Specify --operation only once"
      OPERATION="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      REMAINING+=("$@")
      break
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      REMAINING+=("$1")
      shift
      ;;
  esac
done

[[ -n "$OPERATION" ]] || {
  usage
  die "Specify an operation with -o/--operation"
}

if [[ "$FULL" == true && ${#SERVICES[@]} -gt 0 ]]; then
  die "Use either --full or --service, not both"
fi

if [[ "$FULL" != true && ${#SERVICES[@]} -eq 0 ]]; then
  die "Select one or more services with -s/--service, or use --full"
fi

# Select Compose overlays. The base compose.yml is always included.
declare -A SEEN=()

add_compose_file() {
  local file="$1"
  if [[ -z "${SEEN[$file]+present}" ]]; then
    COMPOSE_FILES+=(-f "$file")
    SEEN["$file"]=1
  fi
}

if [[ "$FULL" == true ]]; then
  add_compose_file overlays/caddy.yml
  add_compose_file overlays/mongodb.yml
else
  for service in "${SERVICES[@]}"; do
    case "$service" in
      core|mongo|mongodb)
        add_compose_file overlays/mongodb.yml
        ;;
      periphery)
        # Periphery is defined in the base compose file.
        ;;
      caddy)
        add_compose_file overlays/caddy.yml
        ;;
      *)
        die "Unknown service: $service"
        ;;
    esac
  done
fi

# Build service targets for commands that support them.
TARGETS=()
if [[ "$FULL" != true ]]; then
  for service in "${SERVICES[@]}"; do
    case "$service" in
      mongodb) TARGETS+=(mongo) ;;
      *)       TARGETS+=("$service") ;;
    esac
  done
fi

compose() {
  docker compose "${COMPOSE_FILES[@]}" "$@"
}

case "$OPERATION" in
  up)
    args=(up -d)
    [[ "$FORCE" == true ]] && args+=(--force-recreate)
    compose "${args[@]}" "${TARGETS[@]}" "${REMAINING[@]}"
    ;;

  down)
    compose down "${REMAINING[@]}"
    ;;

  restart)
    # An optional positional argument targets one container/service.
    if ((${#REMAINING[@]} > 1)); then
      die "restart accepts at most one container/service name"
    fi
    compose restart "${REMAINING[@]}"
    ;;

  update)
    compose pull "${TARGETS[@]}"
    compose down
    args=(up -d)
    [[ "$FORCE" == true ]] && args+=(--force-recreate)
    compose "${args[@]}" "${TARGETS[@]}"
    ;;

  pull)
    compose pull "${TARGETS[@]}" "${REMAINING[@]}"
    ;;

  ps)
    compose ps "${REMAINING[@]}"
    ;;

  logs)
    compose logs -f "${TARGETS[@]}" "${REMAINING[@]}"
    ;;

  *)
    die "Unknown operation: $OPERATION"
    ;;
esac

