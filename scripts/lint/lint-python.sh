#!/usr/bin/env bash
set -euo pipefail

##############################################
# Lint and check Python formatting with Ruff #
##############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/lint-python.sh"
DESCRIPTION="Lint Python files and check formatting using Ruff.

Only failed files and their diagnostics are printed.
The final lines show how many files were checked and how many had failures.
Complete results are saved to the output directory.

Uses the repository's root ruff.toml.
Does not modify files.

With no path specified, searches the entire repository."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} scripts
  ${SCRIPT_NAME} templates
  ${SCRIPT_NAME} templates/example/script.py
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

## Accept --verbose for compatibility without printing successful files.
declare -a script_args=()
parse_verbose_flag "$@"

if ! command -v ruff &>/dev/null; then
  printf '[ERROR] Ruff is not installed.\n' >&2
  exit 2
fi

config_file="${REPO_ROOT}/ruff.toml"

if [[ ! -f "${config_file}" ]]; then
  printf '[ERROR] Ruff configuration not found: %s\n' \
    "${config_file}" >&2
  exit 2
fi

mkdir -p "${OUTPUT_DIR}"

results_file="${OUTPUT_DIR}/ruff.txt"
: >"${results_file}"

## Resolve relative configuration patterns consistently from the repo root.
cd "${REPO_ROOT}"

PATTERN='^.*\.pyi?$'

declare -a target_args=("${script_args[@]}")

if ((${#target_args[@]} == 0)); then
  target_args=("${REPO_ROOT}")
fi

mapfile -t candidates < <(
  resolve_targets "${PATTERN}" "${target_args[@]}"
)

if ((${#candidates[@]} == 0)); then
  printf 'Files checked: 0\nFiles with failures: 0\n'
  exit 0
fi

work_dir="$(mktemp -d)"
trap 'rm -rf -- "${work_dir}"' EXIT

discovery_file="${work_dir}/files.txt"
discovery_errors="${work_dir}/discovery-errors.txt"
lint_output="${work_dir}/lint.txt"
format_output="${work_dir}/format.txt"

## Let Ruff apply its exclusions before counting and checking files.
if ! ruff check \
  --config "${config_file}" \
  --force-exclude \
  --show-files \
  "${candidates[@]}" \
  >"${discovery_file}" 2>"${discovery_errors}"; then
  {
    printf '[ERROR] Ruff file discovery failed.\n'
    cat "${discovery_errors}"
  } >>"${results_file}"

  printf '[ERROR] Ruff file discovery failed.\n' >&2
  cat "${discovery_errors}" >&2
  exit 2
fi

mapfile -t files <"${discovery_file}"

failures=0
checked=0
tool_error=false

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  lint_status=0
  format_status=0

  ruff check \
    --config "${config_file}" \
    --force-exclude \
    --no-fix \
    --quiet \
    --output-format concise \
    "${file}" >"${lint_output}" 2>&1 || lint_status=$?

  ruff format \
    --config "${config_file}" \
    --force-exclude \
    --check \
    --quiet \
    "${file}" >"${format_output}" 2>&1 || format_status=$?

  ((checked += 1))

  if ((lint_status == 0 && format_status == 0)); then
    status="PASS"
  else
    status="FAIL"
    ((failures += 1))
  fi

  if ((lint_status > 1 || format_status > 1)); then
    tool_error=true
  fi

  ## Save all results, including successful files.
  {
    printf '%s %s\n' "${status}" "${relative}"

    printf '$ ruff check --config %q --force-exclude --no-fix --quiet --output-format concise %q\n' \
      "${config_file}" "${file}"
    cat "${lint_output}"

    printf '$ ruff format --config %q --force-exclude --check --quiet %q\n' \
      "${config_file}" "${file}"
    cat "${format_output}"

    printf '\n'
  } >>"${results_file}"

  ## Print only failed files and their diagnostics.
  if [[ "${status}" == "FAIL" ]]; then
    printf 'FAIL %s\n' "${relative}"

    if ((lint_status != 0)); then
      printf 'Lint findings:\n'
      cat "${lint_output}"
    fi

    if ((format_status != 0)); then
      printf 'Formatting findings:\n'
      cat "${format_output}"

      if ((format_status == 1)); then
        printf 'Formatting changes required: %s\n' "${relative}"
      fi
    fi

    printf '\n'
  fi
done

## Print totals after all diagnostics.
printf '\nFiles checked: %d\nFiles with failures: %d\n' \
  "${checked}" "${failures}"

if [[ "${tool_error}" == true ]]; then
  exit 2
fi

if ((failures > 0)); then
  exit 1
fi

exit 0
