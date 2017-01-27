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
