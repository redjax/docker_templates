#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_NAME="./scripts/lint/run-all.sh"
DESCRIPTION="Run all local Docker Compose template linting and validation checks."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --help"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
${SCRIPT_NAME}

${DESCRIPTION}

Usage:
  ${SCRIPT_NAME} [OPTIONS]

Options:
  -h, --help           Show this help message and exit.
      --changed REF    Pass --changed REF to every underlying check.

Examples:
${EXAMPLES}
EOF
  exit 0
fi

declare -a scripts=(
  "${SCRIPT_DIR}/lint-yaml.sh"
  "${SCRIPT_DIR}/validate-compose.sh"
  "${SCRIPT_DIR}/lint-dockerfiles.sh"
)

failed=0

for script in "${scripts[@]}"; do
  printf '\n===== %s =====\n' "$(basename "$script")"

  if ! "$script" "$@"; then
    failed=1
  fi
done

if ((failed)); then
  echo -e '\nOne or more lint/validation checks failed.'
  exit 1
fi

echo -e '\nAll lint/validation checks passed.'
