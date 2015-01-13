#!/bin/bash

GITHUB_BASE_URL="https://raw.githubusercontent.com/urda/urda.bash/master"

diff-bash() {
    # If colordiff is available, use it in place of diff
    if hash colordiff 2>/dev/null; then
        colordiff -u $@
    else
        diff -u $@
    fi
}

diff-bash --label=GitHub <(curl -s $GITHUB_BASE_URL/bashrc) ~/.bashrc
diff-bash --label=GitHub <(curl -s $GITHUB_BASE_URL/bash_aliases) ~/.bash_aliases
diff-bash --label=GitHub <(curl -s $GITHUB_BASE_URL/bash_exports) ~/.bash_exports
diff-bash --label=GitHub <(curl -s $GITHUB_BASE_URL/bash_profile) ~/.bash_profile
diff-bash --label-GitHub <(curl -s $GITHUB_BASE_URL/bash_osx) ~/.bash_osx
