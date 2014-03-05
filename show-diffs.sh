#!/bin/bash

diff-bash() {
    # If colordiff is available, use it in place of diff
    if hash colordiff 2>/dev/null; then
        colordiff -u $@
    else
        diff -u $@
    fi
}

diff-bash ~/.bashrc ./bashrc
diff-bash ~/.bash_aliases ./bash_aliases
diff-bash ~/.bash_exports ./bash_exports
diff-bash ~/.bash_profile ./bash_profile
