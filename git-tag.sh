#!/bin/bash -e
DIR="$(cd "$(dirname "$0")" && pwd)"

echo Setting up git SSH
source $DIR/git-ssh.sh

GIT_VERSION=/tmp/gitversion
if [ ! -f "$GIT_VERSION" ] ; then
    echo Downloading gitversion
    wget -q -O - https://github.com/screwdriver-cd/gitversion/releases/latest \
       | egrep -o '/screwdriver-cd/gitversion/releases/download/v[0-9.]*/gitversion' \
       | wget --base=http://github.com/ -i - -O /tmp/gitversion
    chmod +x $GIT_VERSION
fi

echo Bumping version
$GIT_VERSION --prefix v bump auto | tee VERSION

echo Pushing the new tag to GitHub
git push origin --tags -q
