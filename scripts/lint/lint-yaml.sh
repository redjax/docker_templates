#!/usr/bin/env bash
set -euo pipefail

#################################
# Lint YAML files with yamllint #
#################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/lint_yaml.sh"
DESCRIPTION="Lint YAML files in Docker Compose template directories using yamllint."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} templates/media
  ${SCRIPT_NAME} templates/media/docker_jellyfin/compose.yml
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --verbose
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

declare -a script_args=()
parse_verbose_flag "$@"

PATTERN='^.*/templates/.*\.ya?ml$'

mapfile -t files < <(resolve_targets "${PATTERN}" "${script_args[@]}")

if ((${#files[@]} == 0)); then
  echo "No YAML files found."
  exit 0
fi

results_file="${OUTPUT_DIR}/yamllint.txt"
detailed_results_file="${OUTPUT_DIR}/yamllint-detailed.txt"
yamllint_output="$(mktemp)"

: >"${results_file}"
: >"${detailed_results_file}"

## Run yamllint once for all files. This avoids hundreds of Python and
#  yamllint process startups.
set +e
run_tool yamllint yamllint -c "${REPO_ROOT}/.yamllint" "${files[@]}" \
  >"${yamllint_output}" 2>&1
yamllint_status=$?
set -e

## yamllint prints each failing file as an unindented path, followed by
#  indented findings. Extract the failing file paths from that output.
mapfile -t failed_files < <(
  awk '/^[^[:space:]]/ { print }' "${yamllint_output}"
)

## Build a fast lookup set of failed files.
declare -A failed_file_set=()

for failed_file in "${failed_files[@]}"; do
  failed_file_set["${failed_file}"]=1
done

## Write one compact result per checked file.
for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if [[ -n "${failed_file_set[${file}]:-}" ]]; then
    printf 'FAIL %s\n' "${relative}" >>"${results_file}"
    printf '\n==> %s\n' "${relative}" >>"${detailed_results_file}"

    if [[ "${VERBOSE}" == true ]]; then
      printf 'FAIL %s\n' "${relative}"
    fi
  else
    printf 'PASS %s\n' "${relative}" >>"${results_file}"

    if [[ "${VERBOSE}" == true ]]; then
      printf 'PASS %s\n' "${relative}"
    fi
  fi
done

## Preserve the complete yamllint output for failed files.
cat "${yamllint_output}" >>"${detailed_results_file}"

if [[ "${VERBOSE}" == true ]]; then
  cat "${yamllint_output}"
fi

rm -f "${yamllint_output}"

failures="${#failed_files[@]}"

(
  print_summary "yamllint" "${#files[@]}" "${failures}"
) || true

exit "${yamllint_status}"
