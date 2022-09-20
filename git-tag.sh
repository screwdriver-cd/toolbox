#!/bin/bash -e
DIR="$(cd "$(dirname "$0")" && pwd)"

echo Setting up git SSH
source $DIR/git-ssh.sh

# https://github.com/screwdriver-cd/gitversion/releases
if [ "$SCREWDRIVER" == true ]; then
  GIT_VERSION=/opt/sd/gitversion
else
  GIT_VERSION=/tmp/gitversion
  if [ ! -f "$GIT_VERSION" ] ; then
    echo Downloading gitversion
    wget -q -O - https://api.github.com/repos/screwdriver-cd/gitversion/releases/latest \
      | egrep -o '/screwdriver-cd/gitversion/releases/download/v[0-9.]*/gitversion_linux_amd64' \
      | wget --base=http://github.com/ -i - -O /tmp/gitversion
    chmod +x $GIT_VERSION
  fi
fi
echo Bumping version
$GIT_VERSION --prefix v bump auto | tee VERSION

echo Pushing the new tag to GitHub
git push origin --tags -q
