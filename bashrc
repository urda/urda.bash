# -*- bash -*-
# shellcheck shell=bash
# ~/.bashrc: executed by bash(1) for non-login shells.

################################################################################
# Base Initialization
################################################################################

# If not running interactively, don't do anything.
[[ $- == *i* ]] || return 0

# Set shell options - Keep LINES/COLUMNS in sync, append history
shopt -s checkwinsize histappend

# Add slash on tab through for symlinks
bind 'set mark-symlinked-directories on' 2>/dev/null

################################################################################
# Critical Environment Variables
################################################################################

if [[ -z ${URDABASH_VERSION+x} ]]; then
  readonly URDABASH_VERSION="1.2.2"
  export URDABASH_VERSION
fi

if [[ -z ${URDABASH_VERSION_URL+x} ]]; then
  readonly URDABASH_VERSION_URL="https://raw.githubusercontent.com/urda/urda.bash/refs/heads/master/VERSION"
  export URDABASH_VERSION_URL
fi

if [[ -z ${URDABASH_OS+x} ]]; then
  readonly URDABASH_OS="$(uname -s)"
  export URDABASH_OS
fi

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

################################################################################
# Functions
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

_source_if_exists() {
  # shellcheck source=/dev/null
  [[ -n "${1}" && -r "${1}" ]] && source "${1}"
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

################################################################################
# Sourcing
################################################################################

# Load common export definitions
_source_if_exists "${HOME}/.bash_exports"

# Load common alias definitions
_source_if_exists "${HOME}/.bash_aliases"

# Load any secrets
_source_if_exists "${HOME}/.bash_secrets"

# Let's handle specific systems now
case ${URDABASH_OS} in
  # macOS / OSX
  Darwin)
    _source_if_exists "${HOME}/.bash_osx"
    ;;
  Linux)
    _source_if_exists "${HOME}/.bash_linux"
    ;;
esac

_prepend_path_once "${HOME}/.local/bin"
_prepend_path_once "${HOME}/bin"

################################################################################
# Tooling
################################################################################

# ------------------------------
# 1Password (op)
# ------------------------------
if [[ -z ${URDABASH_LOADED_1PASSWORD+x} ]]; then
  _op_plugins="${XDG_CONFIG_HOME}/op/plugins.sh"
  if [[ -r "${_op_plugins}" ]]; then
    readonly URDABASH_LOADED_1PASSWORD=1
    _source_if_exists "${_op_plugins}"
  else
    readonly URDABASH_LOADED_1PASSWORD=0
  fi
  unset _op_plugins
fi

# ------------------------------
# direnv
# ------------------------------
if command -v direnv >/dev/null 2>&1 && [[ -z ${URDABASH_LOADED_DIRENV+x} ]]; then
  readonly URDABASH_LOADED_DIRENV=1
  eval "$(direnv hook bash)"
else
  readonly URDABASH_LOADED_DIRENV=0
fi

# ------------------------------
# fnm (via Homebrew or standalone)
# ------------------------------
if command -v fnm >/dev/null 2>&1 && [[ -z ${URDABASH_LOADED_FNM+x} ]]; then
  readonly URDABASH_LOADED_FNM=1
  eval "$(fnm env --use-on-cd --shell bash)"
else
  readonly URDABASH_LOADED_FNM=0
fi

################################################################################
# Update Check
################################################################################

_urdabash_version_check "auto"

################################################################################
# Prompt Functions
# ---
# UTF8 References
#
# - $'\xE2\x95\x90' ..... '═'
# - $'\xE2\x95\x94' ..... '╔'
# - $'\xE2\x95\xa0' ..... '╠'
# - $'\xE2\x95\x9A' ..... '╚'
################################################################################

# ╔═[user@host : /current/working/directory]
_ps1_header_line() {
  local outline=${1} green=${2} blue=${3} reset=${4}
  printf '%s%s%s[%s\\u@\\h%s %s: %s\\w%s]%s\\n%s' \
    "${outline}" $'\xE2\x95\x94' $'\xE2\x95\x90' "${green}" "${reset}" "${outline}" "${blue}" "${outline}" "${outline}" "${reset}"
}

# ╠═[git : branch_name]
_ps1_git_line() {
  type __git_ps1 >/dev/null 2>&1 || return 0
  local branch
  branch=$(__git_ps1 "%s") || branch=""
  [[ -n "${branch}" ]] || return 0
  local outline=${1} green=${2} blue=${3} reset=${4}
  printf '%s%s%s[%sgit%s %s: %s%s%s]%s\\n' \
    "${outline}" $'\xE2\x95\xa0' $'\xE2\x95\x90' "${green}" "${reset}" "${outline}" "${blue}" "${branch}" "${outline}" "${reset}"
}

# ╠═[screen : screen_name]
_ps1_screen_line() {
  [[ -n "${STY}" ]] || return 0
  local outline=${1} green=${2} blue=${3} reset=${4}
  printf '%s%s%s[%sscreen%s %s: %s%s%s]%s\\n' \
    "${outline}" $'\xE2\x95\xa0' $'\xE2\x95\x90' "${green}" "${reset}" "${outline}" "${blue}" "${STY}" "${outline}" "${reset}"
}

# ╚═ $
_ps1_footer_line() {
  local outline=${1} term_char=${2} reset=${3}
  printf '%s%s%s %s%s ' "${outline}" $'\xE2\x95\x9A' $'\xE2\x95\x90' "${term_char}" "${reset}"
}

################################################################################
# Prompt Setup
################################################################################

_set_ps1() {
  # Set prompt variables
  local BBlue='\[\e[1;34m\]'
  local BGreen='\[\e[1;32m\]'
  local BRed='\[\e[1;31m\]'
  local BWhite='\[\e[1;37m\]'

  local Color_Off='\[\e[0m\]'
  local Outline=$BWhite
  local TermChar='$'

  # Determine if root
  if (( EUID == 0 )); then
    # We ARE root, change prompt details
    Outline=$BRed
    TermChar='#'
  fi

  local prompt=""
  prompt=$(
    _ps1_header_line "${Outline}" "${BGreen}" "${BBlue}" "${Color_Off}"
    _ps1_git_line "${Outline}" "${BGreen}" "${BBlue}" "${Color_Off}"
    _ps1_screen_line "${Outline}" "${BGreen}" "${BBlue}" "${Color_Off}"
    _ps1_footer_line "${Outline}" "${TermChar}" "${Color_Off}"
  )
  PS1=${prompt}
}

# Use function for prompts
pc=${PROMPT_COMMAND%;}
case ";${pc};" in
  *";_set_ps1;"*)
    PROMPT_COMMAND="${pc}"
    ;;
  *)
    PROMPT_COMMAND="${pc:+${pc};}_set_ps1;"
    ;;
esac
