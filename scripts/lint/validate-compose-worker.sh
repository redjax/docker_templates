#!/usr/bin/env bash
set -euo pipefail

############################################
# Validate one Docker Compose YAML file.   #
#                                          #
# Writes a self-contained result file.     #
# Does not print routine console output.   #
############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

file="${1:?usage: validate-compose-worker.sh FILE}"
relative="${file#"${REPO_ROOT}/"}"

work_dir="${COMPOSE_VALIDATE_WORK_DIR:?COMPOSE_VALIDATE_WORK_DIR is required}"

result_id="$(printf '%s' "${relative}" | md5sum | cut -d' ' -f1)"
result_file="${work_dir}/${result_id}.result"

find_parent_compose() {
  local start_file="$1"
  local current_dir
  local candidate

  current_dir="$(dirname "${start_file}")"

  while [[ "${current_dir}" != "${REPO_ROOT}" && "${current_dir}" != "/" ]]; do
    for candidate in compose.yml compose.yaml; do
      if [[ -f "${current_dir}/${candidate}" ]]; then
        printf '%s\n' "${current_dir}/${candidate}"
        return 0
      fi
    done

    current_dir="$(dirname "${current_dir}")"
  done

  return 1
}

write_result() {
  local status="$1"
  local description="$2"
  local command="$3"
  local captured_output="$4"

  {
    printf 'STATUS: %s\n' "${status}"
    printf 'FILE: %s\n' "${description}"
    printf 'COMMAND: %s\n' "${command}"
    printf 'OUTPUT:\n'
    cat "${captured_output}"
  } >"${result_file}"
}

output_file="$(mktemp)"

trap 'rm -f "${output_file}"' EXIT

## First try the file as a standalone Compose project.
printf -v validation_command \
  'docker compose -f %q config -q' "${file}"

validation_description="${relative}"

if docker compose -f "${file}" config -q >"${output_file}" 2>&1; then
  write_result \
    "PASS" \
    "${validation_description}" \
    "${validation_command}" \
    "${output_file}"

  exit 0
fi

## If standalone validation fails, try the file as an overlay against
#  the nearest ancestor Compose file.
if parent_compose="$(find_parent_compose "${file}")"; then
  if [[ "${parent_compose}" != "${file}" ]]; then
    parent_relative="${parent_compose#"${REPO_ROOT}/"}"
    validation_description="${parent_relative} + ${relative}"

    printf -v validation_command \
      'docker compose -f %q -f %q config -q' \
      "${parent_compose}" "${file}"

    if docker compose \
      -f "${parent_compose}" \
      -f "${file}" \
      config -q >"${output_file}" 2>&1; then
      write_result \
        "PASS" \
        "${validation_description}" \
        "${validation_command}" \
        "${output_file}"

      exit 0
    fi
  fi
fi

## Record the command and description for the last validation attempted.
write_result \
  "FAIL" \
  "${validation_description}" \
  "${validation_command}" \
  "${output_file}"

## Validation failures are recorded in the result file.
#  The parent script aggregates them and determines the final exit status.
exit 0
