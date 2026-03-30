# -*- bash -*-
# shellcheck shell=bash
# ~/.bash_aliases: General Aliases

# REALLY clear the screen
alias clear='printf "\033c"'

# copy with confirmation and feedback
alias cp='cp -iv'

# better looking diff
if command -v colordiff >/dev/null 2>&1; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

# current unix epoch in seconds
alias epoch='date +%s'

# get a UUID on demand
alias get_uuid='python3 -c "import uuid;print(uuid.uuid4())"'

# fetch HTTP response headers only
alias headers='curl -sI'

# long listing format
alias ll='ls -hlF'

# current moon phase
alias moon='curl -sL https://wttr.in/Moon?F'

# move with confirmation and feedback
alias mv='mv -iv'

# print PATH, one entry per line
alias path='echo "$PATH" | tr ":" "\n"'

# print public IP address
alias publicip='curl -sL --max-time 5 https://icanhazip.com'

# quick HTTP server in current directory
alias serve='python3 -m http.server'

# When using sudo, use alias expansion (otherwise sudo ignores your aliases)
alias sudo='sudo '

# terminal weather forecast
alias weather='curl -sL --max-time 5 https://wttr.in?uF'
