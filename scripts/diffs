#!/bin/bash

diff-bash() {
    if hash git 2>/dev/null; then
        git diff $@
    elif hash colordiff 2>/dev/null; then
        # If colordiff is available, use it in place of diff
        colordiff -u $@
    else
        diff -u $@
    fi
}

diff-bash ./bashrc ~/.bashrc
diff-bash ./bash_aliases ~/.bash_aliases
diff-bash ./bash_exports ~/.bash_exports
diff-bash ./bash_profile ~/.bash_profile
diff-bash ./bash_osx ~/.bash_osx
