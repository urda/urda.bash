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

# Load alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Load export definitions
if [ -f ~/.bash_exports ]; then
    . ~/.bash_exports
fi

# If we have a private bin, include it
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

    # Determine if root
    if (( $EUID == 0 )); then
        # We ARE root, change prompt details
        Outline=$BRed
        TermChar='#'
    fi

    # Configure first prompt line
    #
    # ╔═[user@host : /current/working/directory]
    PS1="$Outline╔═[$BGreen\u@\h$Color_Off $Outline: $BBlue\w$Outline]$Color_Off\n"

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

    # Configure final prompt line
    #
    # ╚═ $
    PS1+="$Outline╚═ $TermChar$Color_Off "
}

# Use function for prompts
PROMPT_COMMAND=set_ps1
