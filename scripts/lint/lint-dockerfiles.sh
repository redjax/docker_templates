#!/usr/bin/env bash
set -euo pipefail

##################################
# Lint Dockerfiles with Hadolint #
##################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/lint-dockerfiles.sh"
DESCRIPTION="Lint Dockerfiles in Docker Compose template directories using hadolint.

Only failed files and their diagnostics are printed.
The final lines show how many files were checked and how many had failures.
Complete results are saved to the output directory."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} templates/media
  ${SCRIPT_NAME} templates/media/docker_jellyfin/Dockerfile
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

## Accept --verbose for compatibility without printing successful files.
declare -a script_args=()
parse_verbose_flag "$@"

PATTERN='^.*/templates/.*Dockerfile[^/]*$'

mapfile -t files < <(resolve_targets "${PATTERN}" "${script_args[@]}")

results_file="${OUTPUT_DIR}/hadolint.txt"

: >"${results_file}"

if ((${#files[@]} == 0)); then
  printf 'Files checked: 0\nFiles with failures: 0\n'
  exit 0
fi

failures=0
output_file="$(mktemp)"

trap 'rm -f "${output_file}"' EXIT

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if hadolint --no-color "$file" >"${output_file}" 2>&1; then
    status="PASS"
  else
    status="FAIL"
    ((failures += 1))
  fi

  ## Save all results to the report, including successful files.
  {
    printf '%s %s\n' "${status}" "${relative}"
    printf '$ hadolint --no-color %q\n' "${file}"
    cat "${output_file}"
    printf '\n'
  } >>"${results_file}"

  ## Print only failed files and their diagnostics.
  if [[ "${status}" == "FAIL" ]]; then
    printf 'FAIL %s\n' "${relative}"
    cat "${output_file}"
    printf '\n'
  fi
done

## Print totals after all filenames, line numbers, and rule violations.
printf '\nFiles checked: %d\nFiles with failures: %d\n' \
  "${#files[@]}" "${failures}"

if ((failures > 0)); then
  exit 1
fi

exit 0
