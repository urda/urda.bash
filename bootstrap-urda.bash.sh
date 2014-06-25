#!/bin/bash

prompt_overwrite() {
    local Color_Off='\e[0m'
    local BRed='\e[1;31m'

    echo -en "${BRed}"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "   WARNING: This will overwrite the following"
    echo "            files in your home directory:"
    echo
    echo "       .bashrc"
    echo "       .bash_aliases"
    echo "       .bash_exports"
    echo "       .bash_profile"
    echo
    echo "   From git-master on:"
    echo "       https://github.com/urda/urda.bash"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo -e "${Color_Off}"
}

prompt_overwrite

read -p "Are you sure you want to do this [y/n] ? "
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Downloading .bashrc ..."
    curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bashrc > ~/.bashrc

    echo "Downloading .bash_aliases ..."
    curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bash_aliases > ~/.bash_aliases

    echo "Downloading .bash_exports ..."
    curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bash_exports > ~/.bash_exports

    echo "Downloading .bash_profile ..."
    curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bash_profile > ~/.bash_profile

    echo "All done! You'll need to re-source your ~/.bashrc file to update your shell."
else
    echo "Aborting..."
fi
