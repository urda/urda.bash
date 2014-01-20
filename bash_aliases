# ~/.bash_aliases

# Enable colors
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# long listing format
alias ll='ls -hlFs'

# REALLY clear the screen
alias nuke-clear='printf "\033c"'

# When using sudo, use alias expansion (otherwise sudo ignores your aliases)
alias sudo='sudo '

