#!/usr/bin/env bash
set -euo pipefail

##################################
# Lint Dockerfiles with Hadolint #
##################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/lint_dockerfiles.sh"
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

mapfile -d '' -t script_args < <(parse_verbose_flag "$@")

PATTERN='^.*/templates/.*Dockerfile[^/]*$'

mapfile -t files < <(resolve_targets "${PATTERN}" "${script_args[@]}")

if ((${#files[@]} == 0)); then
  echo "No Dockerfiles found."
  exit 0
fi

failures=0
results_file="${OUTPUT_DIR}/hadolint.txt"
: >"${results_file}"

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if run_tool hadolint hadolint --no-color "$file" >"${results_file}" 2>&1; then
    printf 'PASS %s\n' "${relative}"

    if [[ "${VERBOSE}" == true ]]; then
      cat "${results_file}"
    fi
  else
    printf 'FAIL %s\n' "${relative}"
    cat "${results_file}" >&2
    ((failures += 1))
  fi
done

print_summary "hadolint" "${#files[@]}" "${failures}"
