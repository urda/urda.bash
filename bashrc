# -*- bash -*-
# shellcheck shell=bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Load bash completions
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    # shellcheck source=/dev/null
    source /etc/bash_completion
fi

# Load common alias definitions
if [ -f ~/.bash_aliases ]; then
    # shellcheck source=/dev/null
    source ~/.bash_aliases
fi

# Load common export definitions
if [ -f ~/.bash_exports ]; then
    # shellcheck source=/dev/null
    source ~/.bash_exports
fi

# If we have a private bin, include it at the FRONT of the path
if [ -d "$HOME/bin/" ]; then
    PATH="$HOME/bin:$PATH"
fi

# Let's handle specific systems now
# OSX
if [ "$(uname)" == "Darwin" ]; then
    if [ -f ~/.bash_osx ]; then
        # shellcheck source=/dev/null
        . ~/.bash_osx
    fi
fi

# Configure pyenv
if [ -x "$(command -v pyenv)" ]; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    # v--- Custom Functions ---v

    deactivate () {
        pyenv shell --unset
    }

    lsvirtualenv () {
        pyenv virtualenvs --bare --skip-aliases
    }

    mkvirtualenv () {
        pyenv virtualenv "${@}"
    }

    rmvirtualenv() {
        pyenv uninstall "${@}"
    }

    workon () {
        pyenv shell "${@}"
    }
fi

# Is 1Password CLI available?
if [ -f "${HOME}"/.config/op/plugins.sh ]; then
    # shellcheck source=/dev/null
    source "${HOME}"/.config/op/plugins.sh
fi

set_ps1() {
    # Define some box drawing hex
    local double_horizontal=$'\xE2\x95\x90'     # ═
    local double_down_right=$'\xE2\x95\x94'     # ╔
    local double_vertical_right=$'\xE2\x95\xa0' # ╠
    local double_up_and_right=$'\xE2\x95\x9A'   # ╚

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
        local Outline=$BRed
        local TermChar='#'
    fi

    # Configure first prompt line
    #
    # ╔═[user@host : /current/working/directory]
    PS1="$Outline${double_down_right}${double_horizontal}[$BGreen\\u@\\h$Color_Off $Outline: $BBlue\\w$Outline]$Outline\\n$Color_Off"

    # Screen Checks
    #
    # ╠═[screen : screen_name]
    if [ -n "$STY" ]; then
        # Screen is up
        PS1+="$Outline${double_vertical_right}${double_horizontal}[${BGreen}screen$Color_Off $Outline: $BBlue$STY$Outline]$Color_Off\\n"
    fi

    # Git check
    #
    # ╠═[git : branch_name]
    if type __git_ps1 > /dev/null 2>&1 ; then
        # Git is available, is this a git repo?
        local Git_Branch
        local Git_Branch_Length
        Git_Branch=$(__git_ps1 "%s")
        Git_Branch_Length=${#Git_Branch}

        if (( "$Git_Branch_Length" > 0 )); then
            # We indeed do have branch info
            PS1+="$Outline${double_vertical_right}${double_horizontal}[${BGreen}git$Color_Off $Outline: $BBlue$Git_Branch$Outline]$Color_Off\\n"
        fi
    fi

    # virtualenv check
    #
    # ╠═[virtualenv : virtualenv_name]
    local venv="${PYENV_VERSION}"
    if [[ ${venv} != "" ]]; then
        # ${string##substring}
        # Deletes longest match of $substring from front of $string.
        PS1+="$Outline${double_vertical_right}${double_horizontal}[${BGreen}virtualenv${Color_Off} ${Outline}: ${BBlue}${venv}${Outline}]${Color_Off}\\n"
    fi

    # Configure final prompt line
    #
    # ╚═ $
    PS1+="$Outline${double_up_and_right}${double_horizontal} $TermChar$Color_Off "
}

# Use function for prompts
PROMPT_COMMAND=set_ps1
