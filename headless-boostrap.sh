if [ -z "$1" ]; then
    echo "You must provide a target directory to deploy to!"
    exit 1
fi

TARGET=${1%/}
GITHUB_BASE_URL="https://raw.githubusercontent.com/urda/urda.bash/master"

echo "Downloading .bashrc to ${TARGET}"
curl -s ${GITHUB_BASE_URL}/bashrc > ${TARGET}/.bashrc

echo "Downloading .bash_aliases to ${TARGET}"
curl -s ${GITHUB_BASE_URL}/bash_aliases > ${TARGET}/.bash_aliases

echo "Downloading .bash_exports to ${TARGET}"
curl -s ${GITHUB_BASE_URL}/bash_exports > ${TARGET}/.bash_exports

echo "Downloading .bash_profile to ${TARGET}"
curl -s ${GITHUB_BASE_URL}/bash_profile > ${TARGET}/.bash_profile

echo "Downloading .bash_osx to ${TARGET}"
curl -s ${GITHUB_BASE_URL}/bash_osx > ${TARGET}/.bash_osx

echo "Headless deploy to ${TARGET}/.bash*"

exit 0
