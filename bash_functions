# -*- bash -*-
# shellcheck shell=bash
# ~/.bash_functions: General Functions

################################################################################
# Functions
################################################################################

# Search running processes (filters out the grep process itself).
psg() {
  ps aux | grep -v grep | grep -i "$@"
}

# Extract common archive formats by file extension.
unarc() {
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

################################################################################
# Internal Functions
################################################################################

# Add to the FRONT of the PATH (unless already present).
_prepend_path_once() {
  local dir=${1}
  [[ -d ${dir} ]] || return
  case ":${PATH}:" in
    # Already present
    *":${dir}:"*) ;;
    # Prepend once
    *) PATH="${dir}:${PATH}" ;;
  esac
}

_urdabash_info() {
  local onepassword_status="0"
  local direnv_status="0"
  local fnm_status="0"
  local homebrew_status="0"
  [[ -n ${URDABASH_LOADED_1PASSWORD+x} ]] && onepassword_status="${URDABASH_LOADED_1PASSWORD}"
  [[ -n ${URDABASH_LOADED_DIRENV+x} ]] && direnv_status="${URDABASH_LOADED_DIRENV}"
  [[ -n ${URDABASH_LOADED_FNM+x} ]] && fnm_status="${URDABASH_LOADED_FNM}"
  [[ -n ${URDABASH_LOADED_HOMEBREW+x} ]] && homebrew_status="${URDABASH_LOADED_HOMEBREW}"

  echo "BASH_VERSION ................ ${BASH_VERSION}"
  echo "URDABASH_VERSION ............ ${URDABASH_VERSION}"
  echo "URDABASH_VERSION_URL ........ ${URDABASH_VERSION_URL}"
  echo "URDABASH_OS ................. ${URDABASH_OS}"
  echo "URDABASH_LOADED_1PASSWORD ... ${onepassword_status}"
  echo "URDABASH_LOADED_DIRENV ...... ${direnv_status}"
  echo "URDABASH_LOADED_FNM ......... ${fnm_status}"
  echo "URDABASH_LOADED_HOMEBREW .... ${homebrew_status}"
}

_urdabash_version_check() {
  local state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/urda.bash"
  local stamp="${state_dir}/last_check"
  local cached="${state_dir}/remote_version"
  local version_url="${URDABASH_VERSION_URL}"
  local interval=604800  # 7 days
  local force_check_now=${1:-}

  # Check cached remote version (instant, no network)
  if [ -f "${cached}" ]; then
    local remote
    remote=$(<"${cached}")
    remote=${remote//[[:space:]]/}
    if [ -n "${remote}" ] && [ "${remote}" != "${URDABASH_VERSION}" ]; then
      printf "An urda.bash update is available:\nLocal version:  '%s'\nRemote version: '%s'\n" "${URDABASH_VERSION}" "${remote}" >&2
    fi
  fi

  # Determine if a background fetch is needed
  local now
  local last=0
  now=$(date +%s)
  if [ -f "${stamp}" ]; then
    last=$(stat -c %Y "${stamp}" 2>/dev/null || stat -f %m "${stamp}" 2>/dev/null || echo 0)
  fi
  if [[ ${force_check_now} != now ]] && (( now - last < interval )); then
    return
  fi

  # Background fetch: update timestamp and fetch remote version
  # Suppress job control notifications ([1] PID / [1]+ Done)
  {
    (
      mkdir -p "${state_dir}" || return
      touch "${stamp}" || return

      local fetched
      if command -v curl >/dev/null 2>&1; then
        fetched=$(curl -fs -m 5 "${version_url}" 2>/dev/null) || return
      elif command -v wget >/dev/null 2>&1; then
        fetched=$(wget -qO- --timeout=5 --tries=1 "${version_url}" 2>/dev/null) || return
      else
        return
      fi

      fetched=${fetched//[[:space:]]/}
      [ -n "${fetched}" ] && printf '%s' "${fetched}" > "${cached}"
    ) &
    disown
  } 2>/dev/null
}
