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
# Critical Environment Setup
################################################################################

if [[ -z ${URDABASH_VERSION+x} ]]; then
  readonly URDABASH_VERSION="1.3.1"
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

_source_if_exists() {
  # shellcheck source=/dev/null
  [[ -n "${1}" && -r "${1}" ]] && source "${1}"
}

################################################################################
# Sourcing
################################################################################

# Load common export definitions
_source_if_exists "${HOME}/.bash_exports"

# Load common alias definitions
_source_if_exists "${HOME}/.bash_aliases"

# Load common function definitions
_source_if_exists "${HOME}/.bash_functions"

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
if [[ -z ${URDABASH_LOADED_DIRENV+x} ]]; then
  if command -v direnv >/dev/null 2>&1; then
    readonly URDABASH_LOADED_DIRENV=1
    eval "$(direnv hook bash)"
  else
    readonly URDABASH_LOADED_DIRENV=0
  fi
fi

# ------------------------------
# fnm (via Homebrew or standalone)
# ------------------------------
if [[ -z ${URDABASH_LOADED_FNM+x} ]]; then
  if command -v fnm >/dev/null 2>&1; then
    readonly URDABASH_LOADED_FNM=1
    eval "$(fnm env --use-on-cd --shell bash)"
  else
    readonly URDABASH_LOADED_FNM=0
  fi
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
  local _line
  printf -v _line '%s%s%s[%s\\u@\\h%s %s: %s\\w%s]%s\\n%s' \
    "${outline}" $'\xE2\x95\x94' $'\xE2\x95\x90' "${green}" "${reset}" "${outline}" "${blue}" "${outline}" "${outline}" "${reset}"
  _PS1_BUF+=${_line}
}

# ╠═[git : branch_name]
_ps1_git_line() {
  # Quick builtin check before forking for __git_ps1
  local _dir="${PWD}"
  while [[ "${_dir}" != "/" ]]; do
    [[ -e "${_dir}/.git" ]] && break
    _dir="${_dir%/*}"
    _dir="${_dir:-/}"
  done
  [[ "${_dir}" != "/" ]] || return 0

  type __git_ps1 >/dev/null 2>&1 || return 0
  local branch
  branch=$(__git_ps1 "%s") || branch=""
  [[ -n "${branch}" ]] || return 0
  local outline=${1} green=${2} blue=${3} reset=${4}
  local _line
  printf -v _line '%s%s%s[%sgit%s %s: %s%s%s]%s\\n' \
    "${outline}" $'\xE2\x95\xa0' $'\xE2\x95\x90' "${green}" "${reset}" "${outline}" "${blue}" "${branch}" "${outline}" "${reset}"
  _PS1_BUF+=${_line}
}

# ╠═[screen : screen_name]
_ps1_screen_line() {
  [[ -n "${STY}" ]] || return 0
  local outline=${1} green=${2} blue=${3} reset=${4}
  local _line
  printf -v _line '%s%s%s[%sscreen%s %s: %s%s%s]%s\\n' \
    "${outline}" $'\xE2\x95\xa0' $'\xE2\x95\x90' "${green}" "${reset}" "${outline}" "${blue}" "${STY}" "${outline}" "${reset}"
  _PS1_BUF+=${_line}
}

# ╚═ $
_ps1_footer_line() {
  local outline=${1} term_char=${2} reset=${3}
  local _line
  printf -v _line '%s%s%s %s%s ' "${outline}" $'\xE2\x95\x9A' $'\xE2\x95\x90' "${term_char}" "${reset}"
  _PS1_BUF+=${_line}
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

  _PS1_BUF=""
  _ps1_header_line "${Outline}" "${BGreen}" "${BBlue}" "${Color_Off}"
  _ps1_git_line "${Outline}" "${BGreen}" "${BBlue}" "${Color_Off}"
  _ps1_screen_line "${Outline}" "${BGreen}" "${BBlue}" "${Color_Off}"
  _ps1_footer_line "${Outline}" "${TermChar}" "${Color_Off}"
  PS1=${_PS1_BUF}
  unset _PS1_BUF
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

################################################################################
# Priority PATH Overrides
################################################################################

_prepend_path_once "${HOME}/.local/bin"
_prepend_path_once "${HOME}/bin"
