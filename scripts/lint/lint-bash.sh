#!/usr/bin/env bash
set -euo pipefail

#####################################
# Lint shell scripts with ShellCheck #
#####################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/lint-bash.sh"
DESCRIPTION="Lint shell scripts throughout the repository using ShellCheck.

ShellCheck options:
      --severity LEVEL
      --severity=LEVEL  Minimum severity: error, warning, info, or style.
                        Default: style (show all findings).

With no path specified, searches the entire repository."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} scripts
  ${SCRIPT_NAME} templates/media
  ${SCRIPT_NAME} scripts/lint/run-all.sh
  ${SCRIPT_NAME} --severity error --verbose
  ${SCRIPT_NAME} --severity warning scripts
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --verbose
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

declare -a script_args=()
parse_verbose_flag "$@"

severity="style"
declare -a target_args=()

set -- "${script_args[@]}"

while (($# > 0)); do
  case "$1" in
  --severity=*)
    severity="${1#*=}"
    shift
    ;;
  --severity)
    if (($# < 2)) || [[ -z "$2" || "$2" == -* ]]; then
      printf 'error: --severity requires error, warning, info, or style.\n' >&2
      exit 2
    fi

    severity="$2"
    shift 2
    ;;
  *)
    target_args+=("$1")
    shift
    ;;
  esac
done

case "${severity}" in
error | warning | info | style) ;;
*)
  printf 'error: invalid severity: %s. Expected error, warning, info, or style.\n' \
    "${severity}" >&2
  exit 2
  ;;
esac

PATTERN='^.*\.(sh|bash)$'

if ((${#target_args[@]} == 0)); then
  target_args=("${REPO_ROOT}")
fi

mapfile -t files < <(resolve_targets "${PATTERN}" "${target_args[@]}")

if ((${#files[@]} == 0)); then
  echo "No shell scripts found."
  exit 0
fi

failures=0
results_file="${OUTPUT_DIR}/shellcheck.txt"
output_file="$(mktemp)"

trap 'rm -f "${output_file}"' EXIT

: >"${results_file}"

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if shellcheck --severity="${severity}" --format=gcc --color=never \
    "$file" >"${output_file}" 2>&1; then
    status="PASS"
  else
    status="FAIL"
    ((failures += 1))
  fi

  {
    printf '%s %s\n' "${status}" "${relative}"
    printf '$ shellcheck --severity=%s --format=gcc --color=never %q\n' \
      "${severity}" "${file}"
    cat "${output_file}"
    printf '\n'
  } >>"${results_file}"

  if [[ "${VERBOSE}" == true ]]; then
    printf '%s %s\n' "${status}" "${relative}"
    printf '$ shellcheck --severity=%s --format=gcc --color=never %q\n' \
      "${severity}" "${file}"
    cat "${output_file}"
    printf '\n'
  fi
done

printf 'Severity: %s\n' "${severity}"
printf 'Report: %s\n' "${results_file}"

print_summary "shellcheck" "${#files[@]}" "${failures}"
