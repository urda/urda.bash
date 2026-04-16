# -*- bash -*-
# shellcheck shell=bash
# ~/.bash_aliases: General Aliases

# REALLY clear the screen
alias clear='printf "\033c"'

# random commit message from whatthecommit.com
alias commitjoke='curl -sL --max-time 5 https://whatthecommit.com/index.txt'

# copy with confirmation and feedback
alias cp='cp -iv'

# random dad joke
alias dadjoke='curl -sL --max-time 5 -H "Accept: text/plain" https://icanhazdadjoke.com/ && echo'

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
alias headers='curl -sI --max-time 5'

# long listing format
alias ll='ls -hlF'

# current moon phase
alias moon='curl -sL --max-time 5 https://wttr.in/Moon?F'

# move with confirmation and feedback
alias mv='mv -iv'

# print PATH, one entry per line
alias path='echo "${PATH}" | tr ":" "\n"'

# print public IP address
alias publicip='curl -sL --max-time 5 https://icanhazip.com'

# quick HTTP server in current directory
alias serve='python3 -m http.server'

# print the shrug emoticon
alias shrug='echo "¯\_(ツ)_/¯"'

# When using sudo, use alias expansion (otherwise sudo ignores your aliases)
alias sudo='sudo '

# print the table flip emoticon
alias tableflip='echo "(╯°□°)╯︵ ┻━┻"'

# print the table unflip emoticon
alias tableunflip='echo "┬─┬ノ( º _ ºノ)"'

# current UTC timestamp in ISO 8601 format
alias timestamp='date -u +"%Y-%m-%dT%H:%M:%SZ"'

# terminal weather forecast
alias weather='curl -sL --max-time 5 https://wttr.in?uF'
