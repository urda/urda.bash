#!/bin/bash

set -e

shellcheck bash_aliases --shell=bash -e SC1091,SC2148
shellcheck bash_exports --shell=bash -e SC1091,SC2148
shellcheck bash_osx --shell=bash -e SC1091,SC2148
shellcheck bash_profile --shell=bash -e SC1091,SC2148
shellcheck bashrc --shell=bash -e SC1091,SC2148

echo "OK!"
