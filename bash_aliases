# ~/.bash_aliases

# better looking diff
alias diff='diff -u'

# long listing format
alias ll='ls -hlFs'

# REALLY clear the screen
alias clear='printf "\033c"'

# When using sudo, use alias expansion (otherwise sudo ignores your aliases)
alias sudo='sudo '

# Enable colors for certain commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    # If colordiff is available, use it in place of diff
    if hash colordiff 2>/dev/null; then
        alias diff='colordiff -u'
    fi
fi
