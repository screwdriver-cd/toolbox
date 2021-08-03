#!/bin/bash -e
DIR="$(cd "$(dirname "$0")" && pwd)"

echo Setting up git SSH
source $DIR/git-ssh.sh

# https://github.com/screwdriver-cd/gitversion/releases
GIT_VERSION=/opt/sd/gitversion
echo Bumping version
$GIT_VERSION --prefix v bump auto | tee VERSION

echo Pushing the new tag to GitHub
git push origin --tags -q
