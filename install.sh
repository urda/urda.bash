#!/usr/bin/env bash
#
# install.sh - Bootstrap installer for urda.bash
#
# Usage:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/urda/urda.bash/master/install.sh)"
#
# Downloads and installs urda.bash dotfiles into the user's home directory.
# Existing files will be overwritten after confirmation.
#

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/urda/urda.bash/master"

# ---------------------------------------------------------------------------
# Fetch version and manifest from remote
# ---------------------------------------------------------------------------

echo "Fetching urda.bash..."
if ! VERSION=$(curl -fs -m 10 "${BASE_URL}/VERSION"); then
  echo "Error: failed to fetch VERSION from remote" >&2
  exit 1
fi
VERSION=${VERSION//[[:space:]]/}

if ! MANIFEST=$(curl -fs -m 10 "${BASE_URL}/MANIFEST"); then
  echo "Error: failed to fetch MANIFEST from remote" >&2
  exit 1
fi

if [[ -z ${VERSION} || -z ${MANIFEST} ]]; then
  echo "Error: empty VERSION or MANIFEST from remote" >&2
  exit 1
fi

echo "urda.bash ${VERSION}"

# ---------------------------------------------------------------------------
# Download all managed files to a temporary staging directory
# ---------------------------------------------------------------------------

STAGING=$(mktemp -d)
trap 'rm -rf "${STAGING}"' EXIT
echo "Staging to: ${STAGING}"

while IFS= read -r file; do
  [[ -z ${file} ]] && continue
  echo "  ${file}"
  if ! curl -fs -m 10 -o "${STAGING}/${file}" "${BASE_URL}/${file}"; then
    echo "Error: failed to download ${file}" >&2
    exit 1
  fi
done <<< "${MANIFEST}"

# ---------------------------------------------------------------------------
# Verify downloads (count and non-empty)
# ---------------------------------------------------------------------------

expected=$(echo "${MANIFEST}" | grep -c .)
actual=$(find "${STAGING}" -type f | grep -c .)

if [[ ${expected} -ne ${actual} ]]; then
  echo "Error: expected ${expected} files, got ${actual}" >&2
  exit 1
fi

if [[ -n $(find "${STAGING}" -type f -empty -print -quit) ]]; then
  echo "Error: empty files detected" >&2
  exit 1
fi

echo "Files verified (${actual} files)"

# ---------------------------------------------------------------------------
# Warn about existing files that will be overwritten
# ---------------------------------------------------------------------------

echo ""
while IFS= read -r file; do
  [[ -z ${file} ]] && continue
  if [[ -f "${HOME}/.${file}" ]]; then
    echo "  Will overwrite: ${HOME}/.${file}"
  else
    echo "  Will create:    ${HOME}/.${file}"
  fi
done <<< "${MANIFEST}"

# ---------------------------------------------------------------------------
# Confirm with user (read from /dev/tty since stdin may be a pipe)
# ---------------------------------------------------------------------------

echo ""
read -r -p "Install urda.bash ${VERSION}? [Y/N] " confirm < /dev/tty

if [[ ${confirm} != [yY] ]]; then
  echo "Install cancelled"
  exit 0
fi

# ---------------------------------------------------------------------------
# Copy files to home directory
# ---------------------------------------------------------------------------

while IFS= read -r file; do
  [[ -z ${file} ]] && continue
  cp -v "${STAGING}/${file}" "${HOME}/.${file}"
done <<< "${MANIFEST}"

echo "urda.bash ${VERSION} installed. Open a new shell to use it."
