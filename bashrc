# -*- bash -*-
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
    . /etc/bash_completion
fi

# Load common alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Load common export definitions
if [ -f ~/.bash_exports ]; then
    . ~/.bash_exports
fi

# Let's handle specific systems now
# OSX
if [ "$(uname)" == "Darwin" ]; then
    if [ -f ~/.bash_osx ]; then
        . ~/.bash_osx
    fi
fi

# Configure virtualenv
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    export WORKON_HOME=$HOME/.virtualenvs
    source $(which virtualenvwrapper.sh)
fi

# Ok we are almost done, just add the user's bin now
# If we have a private bin, include it at the FRONT of the path
if [ -d $HOME/bin/ ]; then
    PATH="$HOME/bin:$PATH"
fi

set_ps1() {
    # Set prompt variables
    local BBlue='\[\e[1;34m\]'
    local BGreen='\[\e[1;32m\]'
    local BRed='\[\e[1;31m\]'
    local BWhite='\[\e[1;37m\]'

    local Color_Off='\[\e[0m\]'
    local Outline=$BWhite
    local TermChar='$'
    local HrChar='─'

    # Determine if root
    if (( $EUID == 0 )); then
        # We ARE root, change prompt details
        local Outline=$BRed
        local TermChar='#'
    fi

    # Let's compute current line length, since bash can't count properly with escape sequences
    # Total = Internal Whitespace + Outline Chars + username + hostname + working directory
    local LENGTH_WHITESPACE=2
    local LENGTH_OUTLINE=6

    local LENGTH_USERNAME=$(whoami)
    local LENGTH_USERNAME=${#LENGTH_USERNAME}

    local LENGTH_HOSTNAME=$(hostname -s)
    local LENGTH_HOSTNAME=${#LENGTH_HOSTNAME}

    local LENGTH_DIRECTORY=$(pwd)
    if [[ $(pwd) == $HOME* ]]; then
        # If we are in home, then we need to count it as ~/path/to/foo not the full path
        local LENGTH_DIRECTORY=${LENGTH_DIRECTORY:${#HOME}}
        local LENGTH_DIRECTORY="~$LENGTH_DIRECTORY"
    fi
    local LENGTH_DIRECTORY=${#LENGTH_DIRECTORY}

    # Let's add everything up!
    local PS1_LENGTH=$(($LENGTH_WHITESPACE+$LENGTH_OUTLINE+$LENGTH_USERNAME+$LENGTH_HOSTNAME+$LENGTH_DIRECTORY))
    # And compute the final result, columns minus the free length
    local HR_LENGTH=$(($(tput cols) - $PS1_LENGTH))

    if (( $HR_LENGTH > 0 )); then
        # If we have a value > 0 we will show the line
        local HR=$(eval printf %.0s"$HrChar" {1.."${HR_LENGTH}"})
    else
        # If the available space is 0 or less, we will NOT show the line
        local HR=""
    fi

    # Configure first prompt line
    #
    # ╔═[user@host : /current/working/directory]───── (...)
    PS1="$Outline╔═[$BGreen\u@\h$Color_Off $Outline: $BBlue\w$Outline]$Outline$HR\n$Color_Off"

    # Screen Checks
    #
    # ╠═[screen : screen_name]
    if [ -n "$STY" ]; then
        # Screen is up
        PS1+="$Outline╠═[${BGreen}screen$Color_Off $Outline: $BBlue$STY$Outline]$Color_Off\n"
    fi

    # VCS Checks
    # Git, Hg

    # Git check
    #
    # ╠═[git : branch_name]
    if type __git_ps1 > /dev/null 2>&1 ; then
        # Git is available, is this a git repo?
        local Git_Branch=$(__git_ps1 "%s")
        local Git_Branch_Length=${#Git_Branch}

        if (( "$Git_Branch_Length" > 0 )); then
            # We indeed do have branch info
            PS1+="$Outline╠═[${BGreen}git$Color_Off $Outline: $BBlue$Git_Branch$Outline]$Color_Off\n"
        fi
    fi

    # Hg check
    #
    # ╠═[hg : branch_name]
    local Hg_Branch=$(hg branch 2> /dev/null)
    local Hg_Branch_Length=${#Hg_Branch}

    if (( "$Hg_Branch_Length" > 0 )); then
        # We indeed do have branch info
        PS1+="$Outline╠═[${BGreen}hg$Color_Off $Outline: $BBlue$Hg_Branch$Outline]$Color_Off\n"
    fi

    # virtualenv check
    #
    # ╠═[virtualenv : virtualenv_name]
    if [[ $VIRTUAL_ENV != "" ]]; then
        # ${string##substring}
        # Deletes longest match of $substring from front of $string.
        local venv="${VIRTUAL_ENV##*/}"
        PS1+="$Outline╠═[${BGreen}virtualenv${Color_Off} ${Outline}: ${BBlue}${venv}${Outline}]${Color_Off}\n"
    fi

    # Configure final prompt line
    #
    # ╚═ $
    PS1+="$Outline╚═ $TermChar$Color_Off "
}

# Use function for prompts
PROMPT_COMMAND=set_ps1
