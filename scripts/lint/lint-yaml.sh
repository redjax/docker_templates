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
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

PATTERN='^.*/templates/.*\.ya?ml$'

mapfile -t files < <(resolve_targets "${PATTERN}" "$@")

if ((${#files[@]} == 0)); then
  echo "No YAML files found."
  exit 0
fi

failures=0
results_file="${OUTPUT_DIR}/yamllint.txt"
: >"${results_file}"

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if yamllint -c "${REPO_ROOT}/.yamllint" "$file" >"${results_file}" 2>&1; then
    printf 'PASS %s\n' "${relative}"
  else
    printf 'FAIL %s\n' "${relative}"
    sed 's/^/  /' "${results_file}"
    ((failures += 1))
  fi
done

print_summary "yamllint" "${#files[@]}" "${failures}"
