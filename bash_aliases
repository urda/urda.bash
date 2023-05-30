# -*- bash -*-
# ~/.bash_aliases: General Aliases

# REALLY clear the screen
alias clear='printf "\033c"'

# better looking diff
alias diff='diff -u'

# get a UUID on demand
alias get_uuid='python3 -c "import uuid;print(uuid.uuid4())"'

# long listing format
alias ll='ls -hlFs'

# When using sudo, use alias expansion (otherwise sudo ignores your aliases)
alias sudo='sudo '

# Enable colors for certain commands
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

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
