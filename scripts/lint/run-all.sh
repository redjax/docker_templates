#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_NAME="./scripts/lint/run-all.sh"
DESCRIPTION="Run all local Docker Compose template linting and validation checks."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --verbose
  ${SCRIPT_NAME} --changed origin/main --verbose
  LINT_COMPOSE=false ${SCRIPT_NAME}
  LINT_YAML=false LINT_COMPOSE=false ${SCRIPT_NAME}
  ${SCRIPT_NAME} --help"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
${SCRIPT_NAME}

${DESCRIPTION}

Usage:
  ${SCRIPT_NAME} [OPTIONS] [PATH | FILE]

Options:
  -h, --help           Show this help message and exit.
  -v, --verbose        Pass --verbose to every underlying check.
      --changed REF    Pass --changed REF to every underlying check.

Arguments:
  PATH                 Process matching files beneath a directory.
  FILE                 Pass one specific file to every enabled check.
  (none)               Process matching files beneath templates/.

Environment:
  LINT_YAML            Run yamllint: true or false. Default: true.
  LINT_COMPOSE         Run Compose validation: true or false. Default: true.
  LINT_DOCKERFILES     Run hadolint: true or false. Default: true.
  LINT_BASH            Run ShellCheck: true or false. Default: true.

Examples:
${EXAMPLES}
EOF
  exit 0
fi

LINT_YAML="${LINT_YAML:-true}"
LINT_COMPOSE="${LINT_COMPOSE:-true}"
LINT_DOCKERFILES="${LINT_DOCKERFILES:-true}"
LINT_BASH="${LINT_BASH:-true}"

for variable in LINT_YAML LINT_COMPOSE LINT_DOCKERFILES; do
  case "${!variable}" in
  true | false) ;;
  *)
    printf 'error: %s must be true or false, got: %s\n' \
      "${variable}" "${!variable}" >&2
    exit 2
    ;;
  esac
done

declare -a scripts=()

if [[ "${LINT_YAML}" == true ]]; then
  scripts+=("${SCRIPT_DIR}/lint-yaml.sh")
fi

if [[ "${LINT_COMPOSE}" == true ]]; then
  scripts+=("${SCRIPT_DIR}/validate-compose.sh")
fi

if [[ "${LINT_DOCKERFILES}" == true ]]; then
  scripts+=("${SCRIPT_DIR}/lint-dockerfiles.sh")
fi

if [[ "${LINT_BASH}" == true ]]; then
  scripts+=("${SCRIPT_DIR}/lint-bash.sh")
fi

if ((${#scripts[@]} == 0)); then
  printf 'No lint or validation checks enabled.\n'
  exit 0
fi

failed=0

for script in "${scripts[@]}"; do
  printf '\n[ %s ]\n' "$(basename "$script")"

  if ! "$script" "$@"; then
    failed=1
  fi
done

if ((failed)); then
  printf '\nOne or more lint/validation checks failed.\n'
  exit 1
fi

printf '\nAll lint/validation checks passed.\n'
