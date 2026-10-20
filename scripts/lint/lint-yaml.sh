#!/usr/bin/env bash
set -euo pipefail

#################################
# Lint YAML files with yamllint #
#################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/lint_yaml.sh"
DESCRIPTION="Lint YAML files in Docker Compose template directories using yamllint.

Only files with findings and their diagnostics are printed.
The final lines show how many files were checked and how many had failures.
Complete results are saved to the output directory."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} templates/media
  ${SCRIPT_NAME} templates/media/docker_jellyfin/compose.yml
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

# Accept --verbose for compatibility without printing successful files.
declare -a script_args=()
parse_verbose_flag "$@"

PATTERN='^.*/templates/.*\.ya?ml$'

mapfile -t files < <(resolve_targets "${PATTERN}" "${script_args[@]}")

results_file="${OUTPUT_DIR}/yamllint.txt"
detailed_results_file="${OUTPUT_DIR}/yamllint-detailed.txt"

: >"${results_file}"
: >"${detailed_results_file}"

if ((${#files[@]} == 0)); then
  printf 'Files checked: 0\nFiles with failures: 0\n'
  exit 0
fi

yamllint_output="$(mktemp)"

trap 'rm -f "${yamllint_output}"' EXIT

## Run yamllint once for all files to avoid repeated process startups.
## The parsing below expects standard-format file headings followed
## by indented diagnostics.
yamllint_status=0

run_tool yamllint yamllint \
  --format standard \
  -c "${REPO_ROOT}/.yamllint" \
  "${files[@]}" >"${yamllint_output}" 2>&1 || yamllint_status=$?

## Extract file headings from the captured output.
mapfile -t failed_files < <(
  awk '/^[^[:space:]]/ { print }' "${yamllint_output}"
)

## Build a lookup set of files with findings.
declare -A failed_file_set=()

for failed_file in "${failed_files[@]}"; do
  failed_file_set["${failed_file}"]=1
done

## Save one compact result per checked file.
## Print only files with findings to the console.
failures=0

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if [[ -n "${failed_file_set[${file}]:-}" ]]; then
    ((failures += 1))

    printf 'FAIL %s\n' "${relative}" >>"${results_file}"
    printf 'FAIL %s\n' "${relative}"
  else
    printf 'PASS %s\n' "${relative}" >>"${results_file}"
  fi
done

## Preserve the complete tool output in the detailed report.
cat "${yamllint_output}" >>"${detailed_results_file}"

## Print all diagnostics before the final counts.
if [[ -s "${yamllint_output}" ]]; then
  cat "${yamllint_output}"
fi

## Print totals after all filenames, line numbers, and rule violations.
printf '\nFiles checked: %d\nFailures: %d\n' \
  "${#files[@]}" "${failures}"

exit "${yamllint_status}"
