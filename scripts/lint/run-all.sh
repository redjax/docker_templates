#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_NAME="./scripts/lint/run-all.sh"
DESCRIPTION="Run all repository linting and Docker Compose validation checks."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --verbose
  ${SCRIPT_NAME} --changed origin/main --verbose
  LINT_COMPOSE=false ${SCRIPT_NAME}
  LINT_YAML=false LINT_COMPOSE=false ${SCRIPT_NAME}
  LINT_PYTHON=false ${SCRIPT_NAME}
  ${SCRIPT_NAME} --help"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
${SCRIPT_NAME}

${DESCRIPTION}

Usage:
  ${SCRIPT_NAME} [OPTIONS] [PATH | FILE]

Options:
  -h, --help           Show this help message and exit.
  -v, --verbose        Print complete output from every underlying check.
      --changed REF    Pass --changed REF to every underlying check.

Arguments:
  PATH                 Process matching files beneath a directory.
  FILE                 Pass one specific file to every enabled check.
  (none)               Use each check's default search scope.

Output:
  Default              Print each check's name and file/failure counts.
  --verbose            Also print failed files and detailed diagnostics.

Environment:
  LINT_YAML            Run yamllint: true or false. Default: true.
  LINT_COMPOSE         Run Compose validation: true or false. Default: true.
  LINT_DOCKERFILES     Run hadolint: true or false. Default: true.
  LINT_BASH            Run ShellCheck: true or false. Default: true.
  LINT_PYTHON          Run Ruff lint and formatting checks: true or false. Default: true.

Examples:
${EXAMPLES}
EOF
  exit 0
fi

LINT_YAML="${LINT_YAML:-true}"
LINT_COMPOSE="${LINT_COMPOSE:-true}"
LINT_DOCKERFILES="${LINT_DOCKERFILES:-true}"
LINT_BASH="${LINT_BASH:-true}"
LINT_PYTHON="${LINT_PYTHON:-true}"

for variable in \
  LINT_YAML \
  LINT_COMPOSE \
  LINT_DOCKERFILES \
  LINT_BASH \
  LINT_PYTHON; do
  case "${!variable}" in
  true | false) ;;
  *)
    printf 'error: %s must be true or false, got: %s\n' \
      "${variable}" "${!variable}" >&2
    exit 2
    ;;
  esac
done

verbose=false
declare -a check_args=()

for arg in "$@"; do
  case "${arg}" in
  -v | --verbose)
    verbose=true
    ;;
  *)
    check_args+=("${arg}")
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

if [[ "${LINT_PYTHON}" == true ]]; then
  scripts+=("${SCRIPT_DIR}/lint-python.sh")
fi

if ((${#scripts[@]} == 0)); then
  printf 'No lint or validation checks enabled.\n'
  exit 0
fi

output_file="$(mktemp)" || exit 2

trap 'rm -f -- "${output_file}"' EXIT

failed=0

for script in "${scripts[@]}"; do
  printf '\n[ %s ]\n' "$(basename "${script}")"

  status=0

  if [[ "${verbose}" == true ]]; then
    bash "${script}" "${check_args[@]}" --verbose \
      >"${output_file}" 2>&1 || status=$?
  else
    bash "${script}" "${check_args[@]}" \
      >"${output_file}" 2>&1 || status=$?
  fi

  if ((status != 0)); then
    failed=1
  fi

  if [[ "${verbose}" == true ]]; then
    cat "${output_file}"
  else
    ## Print only the standard summary lines from the underlying script.
    awk '
      /^Files checked: [0-9]+$/ ||
      /^Files with failures: [0-9]+$/ {
        print
      }
    ' "${output_file}"

    ## A tool/setup error may prevent the script from producing totals.
    if ! grep -Eq '^Files checked: [0-9]+$' "${output_file}" ||
      ! grep -Eq '^Files with failures: [0-9]+$' "${output_file}"; then
      printf 'Summary unavailable (exit status: %d). Run with --verbose for details.\n' \
        "${status}"
      failed=1
    fi
  fi
done

if ((failed)); then
  exit 1
fi

exit 0
