# -*- bash -*-
# shellcheck shell=bash
# ~/.bash_aliases: General Aliases

# REALLY clear the screen
alias clear='printf "\033c"'

# better looking diff
if command -v colordiff >/dev/null 2>&1; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

# get a UUID on demand
alias get_uuid='python3 -c "import uuid;print(uuid.uuid4())"'

# long listing format
alias ll='ls -hlF'

# When using sudo, use alias expansion (otherwise sudo ignores your aliases)
alias sudo='sudo '
