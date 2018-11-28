#!/bin/bash

GITHUB_BASE_URL="https://raw.githubusercontent.com/urda/urda.bash/master"

prompt_overwrite() {
    echo "+-------------------------------------------------+"
    echo "| /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ |"
    echo "| /!\ WARNING WARNING WARNING WARNING WARNING /!\ |"
    echo "| /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ |"
    echo "|                                                 |"
    echo "|        This will overwrite the following        |"
    echo "|          files in your home directory:          |"
    echo "|                                                 |"
    echo "|       .bashrc                                   |"
    echo "|       .bash_aliases                             |"
    echo "|       .bash_exports                             |"
    echo "|       .bash_profile                             |"
    echo "|       .bash_osx                                 |"
    echo "|                                                 |"
    echo "|             From [git : master] on:             |"
    echo "|        https://github.com/urda/urda.bash        |"
    echo "+-------------------------------------------------+"
    echo
}

prompt_overwrite

read -p "Are you sure you want to do this [y/n] ? "
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Downloading .bashrc ..."
    curl -s $GITHUB_BASE_URL/bashrc > ~/.bashrc

    echo "Downloading .bash_aliases ..."
    curl -s $GITHUB_BASE_URL/bash_aliases > ~/.bash_aliases

    echo "Downloading .bash_exports ..."
    curl -s $GITHUB_BASE_URL/bash_exports > ~/.bash_exports

    echo "Downloading .bash_profile ..."
    curl -s $GITHUB_BASE_URL/bash_profile > ~/.bash_profile

    echo "Downloading .bash_osx ..."
    curl -s $GITHUB_BASE_URL/bash_osx > ~/.bash_osx

    echo "All done! You'll need to re-source your ~/.bashrc file to update your shell."
else
    echo "Aborting..."
fi
