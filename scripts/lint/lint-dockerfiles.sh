#!/usr/bin/env bash
set -euo pipefail

##################################
# Lint Dockerfiles with Hadolint #
##################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/lint-dockerfiles.sh"
DESCRIPTION="Lint Dockerfiles in Docker Compose template directories using hadolint."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} templates/media
  ${SCRIPT_NAME} templates/media/docker_jellyfin/Dockerfile
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --verbose
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

declare -a script_args=()
parse_verbose_flag "$@"

PATTERN='^.*/templates/.*Dockerfile[^/]*$'

mapfile -t files < <(resolve_targets "${PATTERN}" "${script_args[@]}")

if ((${#files[@]} == 0)); then
  echo "No Dockerfiles found."
  exit 0
fi

failures=0
results_file="${OUTPUT_DIR}/hadolint.txt"
output_file="$(mktemp)"

trap 'rm -f "${output_file}"' EXIT

: >"${results_file}"

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if hadolint --no-color "$file" >"${output_file}" 2>&1; then
    status="PASS"
  else
    status="FAIL"
    ((failures += 1))
  fi

  {
    printf '%s %s\n' "${status}" "${relative}"
    printf '$ hadolint --no-color %q\n' "${file}"
    cat "${output_file}"
    printf '\n'
  } >>"${results_file}"

  if [[ "${VERBOSE}" == true ]]; then
    printf '%s %s\n' "${status}" "${relative}"
    printf '$ hadolint --no-color %q\n' "${file}"
    cat "${output_file}"
    printf '\n'
  fi
done

printf 'Report: %s\n' "${results_file}"

print_summary "hadolint" "${#files[@]}" "${failures}"
