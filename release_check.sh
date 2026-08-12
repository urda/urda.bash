#!/usr/bin/env bash
#
# release_check.sh - Documentation parity checks for urda.bash releases.
#
# Compares three sources of truth that must agree before a release:
#   1. The code:        bash_aliases, bash_functions, bash_osx, bashrc
#   2. The help screen: _urdabash_help output
#   3. The docs:        README.md
#
# Checks name parity between the sources and alphabetical order within
# each list. Exits non-zero if any check fails.
#
# Usage: ./release_check.sh (from the repo root, or via `make release-check`)

set -euo pipefail

cd "$(dirname "${0}")"

FAILURES=0

pass() {
  # Report a passing check.
  # Usage: pass <label>
  printf '%-28s OK\n' "${1}"
}

fail() {
  # Report a failing check with optional detail lines.
  # Usage: fail <label> [detail]...
  local label="${1}"
  shift
  printf '%-28s FAIL\n' "${label}"
  local line
  for line in "${@}"; do
    [[ -n "${line}" ]] && printf '%s\n' "${line}"
  done
  FAILURES=$(( FAILURES + 1 ))
}

check_match() {
  # Compare two newline-separated name lists as sets.
  # Usage: check_match <label> <name_a> <list_a> <name_b> <list_b>
  local label="${1}" name_a="${2}" list_a="${3}" name_b="${4}" list_b="${5}"
  local missing_from_b missing_from_a
  missing_from_b=$(comm -23 <(LC_ALL=C sort <<< "${list_a}") <(LC_ALL=C sort <<< "${list_b}") \
    | sed "s/^/  missing from ${name_b}: /")
  missing_from_a=$(comm -13 <(LC_ALL=C sort <<< "${list_a}") <(LC_ALL=C sort <<< "${list_b}") \
    | sed "s/^/  missing from ${name_a}: /")
  if [[ -z "${missing_from_b}" && -z "${missing_from_a}" ]]; then
    pass "${label}"
  else
    fail "${label}" "${missing_from_b}" "${missing_from_a}"
  fi
}

check_sorted() {
  # Verify a newline-separated name list is in alphabetical order.
  # Usage: check_sorted <label> <list>
  local label="${1}" list="${2}"
  local disorder
  if disorder=$(LC_ALL=C sort -c 2>&1 <<< "${list}"); then
    pass "${label}"
  else
    fail "${label}" "  ${disorder}"
  fi
}

help_section() {
  # Print the first word of each entry in a help-screen section.
  # Usage: help_section <heading>   (e.g. help_section "Aliases:")
  printf '%s\n' "${HELP_OUTPUT}" \
    | sed -n "/^${1}\$/,/^\$/p" \
    | sed '1d' \
    | awk 'NF {print $1}'
}

readme_section() {
  # Print the backticked bullet names under an exact README heading.
  # Usage: readme_section <heading line>   (e.g. readme_section "### Aliases")
  # shellcheck disable=SC2016  # $0 belongs to awk, not the shell
  awk -v heading="${1}" '$0 == heading {found=1; next} found && /^#/ {exit} found' README.md \
    | sed -nE 's/^- `([A-Za-z_]+)`.*/\1/p'
}

################################################################################
# Extract the lists
################################################################################

HELP_OUTPUT=$(bash -c 'source ./bash_functions && _urdabash_help')

ALIASES_CODE=$(sed -nE 's/^[[:space:]]*alias ([A-Za-z_]+)=.*/\1/p' bash_aliases | uniq)
ALIASES_HELP=$(help_section "Aliases:")
ALIASES_README=$(readme_section "### Aliases")

FUNCTIONS_FILE=$(sed -nE 's/^([a-z][A-Za-z0-9_]*)\(\) \{.*/\1/p' bash_functions)
FUNCTIONS_OSX=$(sed -nE 's/^[[:space:]]*(update_brew)\(\) \{.*/\1/p' bash_osx)
FUNCTIONS_CODE=$(printf '%s\n%s' "${FUNCTIONS_FILE}" "${FUNCTIONS_OSX}")
FUNCTIONS_HELP=$(help_section "Functions:")
FUNCTIONS_README=$(readme_section "### Functions")

INTERNALS_FILE=$(sed -nE 's/^(_[A-Za-z0-9_]+)\(\) \{.*/\1/p' bash_functions)
INTERNALS_CODE=$(printf '%s\n' "${INTERNALS_FILE}" | grep '^_urdabash_')
INTERNALS_HELP=$(help_section "Internal:")
INTERNALS_README=$(readme_section "#### Internal Functions")

################################################################################
# Aliases
################################################################################

check_match "aliases: code vs help" "bash_aliases" "${ALIASES_CODE}" "help" "${ALIASES_HELP}"
check_match "aliases: code vs README" "bash_aliases" "${ALIASES_CODE}" "README" "${ALIASES_README}"
check_sorted "aliases: file order" "${ALIASES_CODE}"
check_sorted "aliases: help order" "${ALIASES_HELP}"
check_sorted "aliases: README order" "${ALIASES_README}"

################################################################################
# Functions
################################################################################

check_match "functions: code vs help" "code" "${FUNCTIONS_CODE}" "help" "${FUNCTIONS_HELP}"
check_match "functions: code vs README" "code" "${FUNCTIONS_CODE}" "README" "${FUNCTIONS_README}"
check_sorted "functions: file order" "${FUNCTIONS_FILE}"
check_sorted "functions: help order" "${FUNCTIONS_HELP}"
check_sorted "functions: README order" "${FUNCTIONS_README}"

################################################################################
# Internal functions
#
# Contract: the help screen lists exactly the user-runnable _urdabash_*
# commands. README documents those plus any loader primitives, so README
# must be a superset of help, and every README entry must exist in code.
################################################################################

check_match "internal: code vs help" "code" "${INTERNALS_CODE}" "help" "${INTERNALS_HELP}"

MISSING_README=$(comm -23 <(LC_ALL=C sort <<< "${INTERNALS_HELP}") <(LC_ALL=C sort <<< "${INTERNALS_README}") \
  | sed 's/^/  in help but not README: /')
if [[ -z "${MISSING_README}" ]]; then
  pass "internal: README superset"
else
  fail "internal: README superset" "${MISSING_README}"
fi

UNDEFINED=""
while IFS= read -r name; do
  [[ -z "${name}" ]] && continue
  if ! grep -qE "^[[:space:]]*${name}\(\)" bashrc bash_functions bash_osx; then
    UNDEFINED="${UNDEFINED}  in README but not defined in code: ${name}"$'\n'
  fi
done <<< "${INTERNALS_README}"
if [[ -z "${UNDEFINED}" ]]; then
  pass "internal: README exists"
else
  fail "internal: README exists" "${UNDEFINED%$'\n'}"
fi

check_sorted "internal: file order" "${INTERNALS_FILE}"
check_sorted "internal: help order" "${INTERNALS_HELP}"
check_sorted "internal: README order" "${INTERNALS_README}"

################################################################################
# Summary
################################################################################

echo ""
if (( FAILURES > 0 )); then
  echo "release-check: ${FAILURES} check(s) failed"
  exit 1
fi
echo "release-check: all checks passed"
