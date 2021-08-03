#!/bin/bash -e
# GIT_KEY = SSH Deployment key
# NPM_TOKEN = NPM token for publishing the module
if [ -z "$GIT_KEY" ] || [ -z "$NPM_TOKEN" ]; then
  echo Unable to publish, missing environment variables
  exit 2
fi
DIR="$(cd "$(dirname "$0")" && pwd)"

echo Setting up git SSH
source $DIR/git-ssh.sh

echo Setting up npm secrets
npm config set access public > /dev/null 2>&1
npm config set //registry.npmjs.org/:_authToken $NPM_TOKEN > /dev/null 2>&1

echo Bumping the version
./node_modules/.bin/npm-auto-version

echo Publish the package
npm publish

echo Push the new tag to GitHub
git push origin --tags -q

echo Tee latest tag to VERSION
# https://github.com/screwdriver-cd/gitversion/releases
if [ "$SCREWDRIVER" == true ]; then
  GIT_VERSION=/opt/sd/gitversion
else
  GIT_VERSION=/tmp/gitversion
  if [ ! -f "$GIT_VERSION" ] ; then
    echo Downloading gitversion
    wget -q -O - https://github.com/screwdriver-cd/gitversion/releases/latest \
      | egrep -o '/screwdriver-cd/gitversion/releases/download/v[0-9.]*/gitversion_linux_amd64' \
      | wget --base=http://github.com/ -i - -O /tmp/gitversion
    chmod +x $GIT_VERSION
  fi
fi

echo Getting latest version
$GIT_VERSION --prefix v show | tee VERSION
