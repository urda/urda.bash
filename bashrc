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

# Make less more friendly for non-text input files, see lesspipe(1)
if lesspipe_bin=$(command -v lesspipe); then
  eval "$(SHELL=/bin/sh "${lesspipe_bin}")"
fi

# Load bash completions
if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
    # shellcheck source=/dev/null
    source /etc/bash_completion
fi

################################################################################
# Critical Environment Variables
################################################################################

if [[ -z ${URDABASH_VERSION+x} ]]; then
  readonly URDABASH_VERSION="1.1.0"
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

# Add to the END of the PATH (unless already present).
_postpend_path_once() {
  local dir=${1}
  [[ -d ${dir} ]] || return
  case ":${PATH}:" in
    # Already present
    *":${dir}:"*) ;;
    # Postpend once
    *) PATH="${PATH}:${dir}" ;;
  esac
}

_source_if_exists() {
  # shellcheck source=/dev/null
  [[ -n "${1}" && -r "${1}" ]] && source "${1}"
}

_urdabash_info() {
  local direnv_status="0"
  local nvm_status="0"
  local pyenv_status="0"

  [[ -n ${URDABASH_LOADED_DIRENV+x} ]] && direnv_status="${URDABASH_LOADED_DIRENV}"
  [[ -n ${URDABASH_LOADED_NVM+x} ]] && nvm_status="${URDABASH_LOADED_NVM}"
  [[ -n ${URDABASH_LOADED_PYENV+x} ]] && pyenv_status="${URDABASH_LOADED_PYENV}"

  echo "URDABASH_VERSION ......... ${URDABASH_VERSION}"
  echo "URDABASH_VERSION_URL ..... ${URDABASH_VERSION_URL}"
  echo "URDABASH_OS .............. ${URDABASH_OS}"
  echo "URDABASH_LOADED_DIRENV ... ${direnv_status}"
  echo "URDABASH_LOADED_NVM ...... ${nvm_status}"
  echo "URDABASH_LOADED_PYENV .... ${pyenv_status}"
}

_urdabash_version_check() {
  local interval=604800  # 7 days
  local state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/urda.bash"
  local stamp="${state_dir}/last_check" now last=0
  local version_url="${URDABASH_VERSION_URL}"
  local force_check_now=${1:-}

  now=$(date +%s)
  if [ -f "${stamp}" ]; then
    last=$(stat -f %m "${stamp}" 2>/dev/null || stat -c %Y "${stamp}" 2>/dev/null || echo 0)
  fi
  if [[ ${force_check_now} != now ]] && (( now - last < interval )); then
    return
  fi

  # Update state timestamp
  if ! mkdir -p "${state_dir}"; then
    printf 'urda.bash update check skipped: cannot create %s\n' "${state_dir}" >&2
    return
  fi
  if ! touch "${stamp}"; then
    printf 'urda.bash update check skipped: cannot write %s\n' "${stamp}" >&2
    return
  fi

  local remote
  if command -v curl >/dev/null 2>&1; then
    remote=$(curl -fs -m 2 "${version_url}" 2>/dev/null) || return
  elif command -v wget >/dev/null 2>&1; then
    remote=$(wget -qO- --timeout=2 --tries=1 "${version_url}" 2>/dev/null) || return
  else
    return
  fi

  remote=${remote//[[:space:]]/}
  [ -z "${remote}" ] && return
  [ "${remote}" != "${URDABASH_VERSION}" ] && \
    printf "An urda.bash update is available:\nLocal version:  '%s'\nRemote version: '%s'\n" "${URDABASH_VERSION}" "${remote}" >&2
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
_source_if_exists "${XDG_CONFIG_HOME}/op/plugins.sh"

# ------------------------------
# direnv
# ------------------------------
if command -v direnv >/dev/null 2>&1 && [[ -z ${URDABASH_LOADED_DIRENV+x} ]]; then
  readonly URDABASH_LOADED_DIRENV=1
  eval "$(direnv hook bash)"
fi

# ------------------------------
# NVM (via ~/.nvm or Homebrew)
# ------------------------------
if [[ -z ${URDABASH_LOADED_NVM+x} ]]; then
  readonly URDABASH_LOADED_NVM=1
  export NVM_DIR="${HOME}/.nvm"
  command -v brew >/dev/null 2>&1 && nvm_brew_prefix="$(brew --prefix nvm 2>/dev/null)"

  if [ -s "${HOME}/.nvm/nvm.sh" ]; then
    _source_if_exists "${NVM_DIR}/nvm.sh"
    _source_if_exists "${NVM_DIR}/bash_completion"
  elif [ -n "${nvm_brew_prefix}" ] && [ -f "${nvm_brew_prefix}/nvm.sh" ]; then
    _source_if_exists "${nvm_brew_prefix}/nvm.sh"
    _source_if_exists "${nvm_brew_prefix}/etc/bash_completion.d/nvm"
  fi

  unset nvm_brew_prefix
fi

# ------------------------------
# pyenv
# ------------------------------
if command -v pyenv >/dev/null 2>&1 && [[ -z ${URDABASH_LOADED_PYENV+x} ]]; then
  readonly URDABASH_LOADED_PYENV=1
  export PYENV_ROOT="${HOME}/.pyenv"

  _prepend_path_once "${PYENV_ROOT}/bin"

  eval "$(pyenv init -)"
  if command -v pyenv-virtualenv >/dev/null 2>&1; then
    eval "$(pyenv virtualenv-init -)"

    lsvirtualenv () { pyenv virtualenvs --bare --skip-aliases; }
    mkvirtualenv () { pyenv virtualenv "${@}"; }
    rmvirtualenv () { pyenv uninstall "${@}"; }
  fi
fi

################################################################################
# Update Check
################################################################################

_urdabash_version_check "noop"

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

# ╠═[virtualenv : virtualenv_name]
_ps1_virtualenv_line() {
  local outline=${1} green=${2} blue=${3} reset=${4} venv_path=${5}
  [[ -n "${venv_path}" ]] || return 0
  local venv=${venv_path##*/}  # take only the last path segment
  printf '%s%s%s[%svirtualenv%s %s: %s%s%s]%s\\n' \
    "${outline}" $'\xE2\x95\xa0' $'\xE2\x95\x90' "${green}" "${reset}" "${outline}" "${blue}" "${venv}" "${outline}" "${reset}"
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
    _ps1_virtualenv_line "${Outline}" "${BGreen}" "${BBlue}" "${Color_Off}" "${PYENV_VIRTUAL_ENV}"
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
