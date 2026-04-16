# -*- bash -*-
# shellcheck shell=bash
# ~/.bash_functions: General Functions

################################################################################
# Functions
################################################################################

bak() {
  # Back up a file with a .bak extension.
  # Usage: bak <file>
  cp -v "${1}" "${1}.bak"
}

coinflip() {
  # Flip a coin.
  # Usage: coinflip
  (( RANDOM % 2 )) && echo "heads" || echo "tails"
}

mkcd() {
  # Create a directory and cd into it in one step.
  # Usage: mkcd <directory>
  mkdir -p "${1}" && cd "${1}" || return
}

psg() {
  # Search running processes by name.
  # Filters out the grep process itself to avoid false matches.
  # Usage: psg <pattern>
  ps aux | grep -v grep | grep -i "${@}"
}

roll() {
  # Roll a die (d6 by default, or specify sides).
  # Usage: roll [sides]
  echo $(( RANDOM % ${1:-6} + 1 ))
}

tempdir() {
  # Create and cd into a disposable temporary directory.
  # Usage: tempdir
  cd "$(mktemp -d)" || return
}

unarc() {
  # Extract common archive formats by file extension.
  # Supports: tar.bz2, tar.gz, tar.lzma, tar.xz, tar, 7z, bz2, gz, lzma, rar, xz, Z, zip
  # Usage: unarc <file>
  if [ ! -f "${1}" ]; then
    echo "'${1}' is not a valid file"
    return 1
  fi
  case "${1}" in
    *.tar.bz2|*.tbz2) tar xvjf "${1}"      ;;  # x=extract v=verbose j=bzip2 f=file
    *.tar.gz|*.tgz)   tar xvzf "${1}"      ;;  # x=extract v=verbose z=gzip f=file
    *.tar.lzma)       tar xvf "${1}"       ;;  # x=extract v=verbose f=file (auto-detects lzma)
    *.tar.xz)         tar xvJf "${1}"      ;;  # x=extract v=verbose J=xz f=file
    *.tar)            tar xvf "${1}"       ;;  # x=extract v=verbose f=file (no compression)
    *.7z)             7z x "${1}"          ;;  # x=extract with full paths, verbose by default
    *.bz2)            bunzip2 -v "${1}"    ;;  # -v=verbose, decompress bzip2 (not a tar)
    *.gz)             gunzip -v "${1}"     ;;  # -v=verbose, decompress gzip (not a tar)
    *.lzma)           unlzma -v "${1}"     ;;  # -v=verbose, decompress lzma (not a tar)
    *.rar)            7z x "${1}"          ;;  # x=extract with full paths, verbose by default
    *.xz)             unxz -v "${1}"       ;;  # -v=verbose, decompress xz (not a tar)
    *.Z)              uncompress -v "${1}" ;;  # -v=verbose, legacy Unix compress format
    *.zip)            unzip "${1}"         ;;  # verbose by default
    *)                echo "'${1}' cannot be extracted via unarc()" ;;
  esac
}

_unarc_completions() {
  # Tab-completion for unarc: suggest archive files and directories.
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local files
  mapfile -t files < <(compgen -f -- "${cur}")
  for f in "${files[@]}"; do
    if [[ -d "${f}" ]]; then
      COMPREPLY+=( "${f}" )
    else
      case "${f}" in
        *.tar.bz2|*.tbz2|*.tar.gz|*.tgz|*.tar.lzma|*.tar.xz|*.tar| \
        *.7z|*.bz2|*.gz|*.lzma|*.rar|*.xz|*.Z|*.zip)
          COMPREPLY+=( "${f}" )
          ;;
      esac
    fi
  done
}
complete -o filenames -F _unarc_completions unarc

################################################################################
# Internal Functions
################################################################################

_prepend_path_once() {
  # Prepend a directory to PATH if it exists and is not already present.
  # Usage: _prepend_path_once <directory>
  local dir=${1}
  [[ -d ${dir} ]] || return
  case ":${PATH}:" in
    # Already present
    *":${dir}:"*) ;;
    # Prepend once
    *) PATH="${dir}:${PATH}" ;;
  esac
}

_urdabash_help() {
  # Print a quick reference of all urda.bash aliases and functions.
  echo "urda.bash ${URDABASH_VERSION} - Quick Reference"
  echo ""
  echo "Aliases:"
  echo "  clear ........... Hard reset the terminal screen"
  echo "  commitjoke ...... Random commit message from whatthecommit.com"
  echo "  cp .............. Copy with overwrite confirmation and verbose output"
  echo "  dadjoke ......... Random dad joke from icanhazdadjoke.com"
  echo "  diff ............ Unified diff format, with color via colordiff when available"
  echo "  epoch ........... Print current unix timestamp (seconds)"
  echo "  get_uuid ........ Generate a random UUID"
  echo "  headers ......... Fetch HTTP response headers only"
  echo "  ll .............. Long listing format (ls -hlF)"
  echo "  moon ............ Current moon phase via wttr.in"
  echo "  mv .............. Move with overwrite confirmation and verbose output"
  echo "  path ............ Print PATH entries, one per line"
  echo "  publicip ........ Print public IP address via icanhazip.com"
  echo "  serve ........... Start a quick HTTP server (port 8000)"
  echo "  shrug ........... Print the shrug emoticon"
  echo "  sudo ............ Preserves alias expansion under sudo"
  echo "  tableflip ....... Print the table flip emoticon"
  echo "  tableunflip ..... Print the table unflip emoticon"
  echo "  timestamp ....... Current UTC timestamp (ISO 8601)"
  echo "  weather ......... Terminal weather forecast via wttr.in"
  echo ""
  echo "Functions:"
  echo "  bak ............. Back up a file with a .bak extension"
  echo "  coinflip ........ Flip a coin"
  echo "  mkcd ............ Create a directory and cd into it"
  echo "  psg ............. Search running processes by name"
  echo "  roll ............ Roll a die (d6 default, or specify sides)"
  echo "  tempdir ......... Create and cd into a disposable temp directory"
  echo "  unarc ........... Extract common archive formats"
  echo "  update_brew ..... Run full Homebrew maintenance (macOS only)"
  echo ""
  echo "Internal:"
  echo "  _urdabash_help ............. This help screen"
  echo "  _urdabash_info ............. Print loaded module status"
  echo "  _urdabash_update ........... Self-update urda.bash from GitHub"
  echo "  _urdabash_version_check .... Check for a newer release (pass 'now' to force)"
}

_urdabash_info() {
  # Print urda.bash configuration and loaded module status.
  local onepassword_status="0"
  local direnv_status="0"
  local fnm_status="0"
  local homebrew_status="0"
  local local_status="0"
  local pnpm_status="0"
  [[ -n ${URDABASH_LOADED_1PASSWORD+x} ]] && onepassword_status="${URDABASH_LOADED_1PASSWORD}"
  [[ -n ${URDABASH_LOADED_DIRENV+x} ]] && direnv_status="${URDABASH_LOADED_DIRENV}"
  [[ -n ${URDABASH_LOADED_FNM+x} ]] && fnm_status="${URDABASH_LOADED_FNM}"
  [[ -n ${URDABASH_LOADED_HOMEBREW+x} ]] && homebrew_status="${URDABASH_LOADED_HOMEBREW}"
  [[ -n ${URDABASH_LOADED_LOCAL+x} ]] && local_status="${URDABASH_LOADED_LOCAL}"
  [[ -n ${URDABASH_LOADED_PNPM+x} ]] && pnpm_status="${URDABASH_LOADED_PNPM}"

  echo "BASH_VERSION ................ ${BASH_VERSION}"
  echo "URDABASH_VERSION ............ ${URDABASH_VERSION}"
  echo "URDABASH_VERSION_URL ........ ${URDABASH_VERSION_URL}"
  echo "URDABASH_OS ................. ${URDABASH_OS}"
  echo "URDABASH_LOADED_1PASSWORD ... ${onepassword_status}"
  echo "URDABASH_LOADED_DIRENV ...... ${direnv_status}"
  echo "URDABASH_LOADED_FNM ......... ${fnm_status}"
  echo "URDABASH_LOADED_HOMEBREW .... ${homebrew_status}"
  echo "URDABASH_LOADED_LOCAL ....... ${local_status}"
  echo "URDABASH_LOADED_PNPM ........ ${pnpm_status}"
}

_urdabash_version_check() {
  # Check for a newer urda.bash release on GitHub.
  # Reads a cached remote version for instant comparison, then schedules
  # a background fetch if the cache is stale (older than 7 days).
  # Usage: _urdabash_version_check [now]
  #   now - skip the interval check and force a background fetch
  local state_dir="${XDG_STATE_HOME}/urda.bash"
  local cached="${state_dir}/remote_version"
  local force_check_now=${1:-}  # pass "now" to skip interval and force fetch
  local interval=604800  # 7 days
  local last_check_timestamp="${state_dir}/last_check"

  # Check cached remote version (instant, no network)
  if [ -f "${cached}" ]; then
    local remote
    remote=$(<"${cached}")
    remote=${remote//[[:space:]]/}
    if [ -n "${remote}" ] && [ "${remote}" != "${URDABASH_VERSION}" ]; then
      local newest
      newest=$(printf '%s\n%s' "${remote}" "${URDABASH_VERSION}" | sort -V | tail -1)
      if [ "${newest}" = "${remote}" ]; then
        printf "An urda.bash update is available:\nLocal version:  '%s'\nRemote version: '%s'\nRun '_urdabash_update' to update.\n" "${URDABASH_VERSION}" "${remote}" >&2
      fi
    fi
  fi

  # Determine if a background fetch is needed
  local now
  local last=0
  now=$(date +%s)
  if [ -f "${last_check_timestamp}" ]; then
    last=$(stat -c %Y "${last_check_timestamp}" 2>/dev/null || stat -f %m "${last_check_timestamp}" 2>/dev/null || echo 0)
  fi
  if [[ ${force_check_now} != now ]] && (( now - last < interval )); then
    return
  fi

  # Background fetch: update timestamp and fetch remote version
  # Suppress job control notifications ([1] PID / [1]+ Done)
  {
    (
      mkdir -p "${state_dir}" || return
      touch "${last_check_timestamp}" || return

      command -v curl >/dev/null 2>&1 || return
      local fetched
      fetched=$(curl -fs -m 5 "${URDABASH_VERSION_URL}" 2>/dev/null) || return

      fetched=${fetched//[[:space:]]/}
      [ -n "${fetched}" ] && printf '%s' "${fetched}" > "${cached}"
    ) &
    disown
  } 2>/dev/null
}

_urdabash_update() {
  # Self-update urda.bash by fetching the latest files from GitHub.
  # Downloads VERSION and MANIFEST from remote, stages all managed files
  # to a cache directory, verifies the download, and copies to ~/.
  # Requires curl. No git required.
  local base_url="${URDABASH_VERSION_URL%/*}"
  local cache_dir="${XDG_CACHE_HOME}/urda.bash/upgrade"
  local actual_count
  local confirm
  local expected_count
  local file
  local remote_manifest
  local remote_version

  # Require curl
  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required for updates" >&2
    return 1
  fi

  # Fetch remote version
  echo "Checking for updates..."
  remote_version=$(curl -fs -m 10 "${base_url}/VERSION")
  remote_version=${remote_version//[[:space:]]/}

  if [[ -z ${remote_version} ]]; then
    echo "Error: failed to fetch remote version" >&2
    return 1
  fi

  local newest
  newest=$(printf '%s\n%s' "${remote_version}" "${URDABASH_VERSION}" | sort -V | tail -1)
  if [[ ${newest} == "${URDABASH_VERSION}" ]]; then
    echo "Already up to date, local is ${URDABASH_VERSION}, remote is ${remote_version}"
    return 0
  fi

  echo "Update available: ${URDABASH_VERSION} -> ${remote_version}"

  # Fetch remote MANIFEST
  echo "Downloading update MANIFEST..."
  remote_manifest=$(curl -fs -m 10 "${base_url}/MANIFEST")

  if [[ -z ${remote_manifest} ]]; then
    echo "Error: failed to fetch remote MANIFEST" >&2
    return 1
  fi

  # Download files listed in MANIFEST
  rm -rf "${cache_dir}"
  mkdir -p "${cache_dir}"

  while IFS= read -r file; do
    [[ -z ${file} ]] && continue
    echo "  Downloading ${file}..."
    if ! curl -fs -m 10 -o "${cache_dir}/${file}" "${base_url}/${file}"; then
      echo "Error: failed to download ${file}" >&2
      rm -rf "${cache_dir}"
      return 1
    fi
  done <<< "${remote_manifest}"

  # Verify downloads
  expected_count=$(echo "${remote_manifest}" | grep -c .)
  actual_count=$(find "${cache_dir}" -type f | grep -c .)

  if [[ ${expected_count} -ne ${actual_count} ]]; then
    echo "Error: expected ${expected_count} files, got ${actual_count}" >&2
    rm -rf "${cache_dir}"
    return 1
  fi

  if [[ -n $(find "${cache_dir}" -type f -empty -print -quit) ]]; then
    echo "Error: empty files detected in download" >&2
    rm -rf "${cache_dir}"
    return 1
  fi

  echo "Files staged and verified (${actual_count} files)"

  # Confirm with user
  read -r -p "Update urda.bash ${URDABASH_VERSION} -> ${remote_version}? [Y/N] " confirm

  if [[ ${confirm} != [yY] ]]; then
    echo "Update cancelled"
    rm -rf "${cache_dir}"
    return 0
  fi

  # Copy files to home directory
  while IFS= read -r file; do
    [[ -z ${file} ]] && continue
    cp -v "${cache_dir}/${file}" "${HOME}/.${file}"
  done <<< "${remote_manifest}"

  # Cleanup and report
  rm -rf "${cache_dir}"
  echo "urda.bash updated: ${URDABASH_VERSION} -> ${remote_version}"
  echo "Open a new shell to use the new version."
}
