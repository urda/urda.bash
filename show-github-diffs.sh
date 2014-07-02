#!/bin/bash

diff-bash() {
    # If colordiff is available, use it in place of diff
    if hash colordiff 2>/dev/null; then
        colordiff -u $@
    else
        diff -u $@
    fi
}

diff-bash --label=GitHub <(curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bashrc) ~/.bashrc
diff-bash --label=GitHub <(curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bash_aliases) ~/.bash_aliases
diff-bash --label=GitHub <(curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bash_exports) ~/.bash_exports
diff-bash --label=GitHub <(curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bash_profile) ~/.bash_profile
