#!/bin/bash -e
# GIT_KEY = SSH Deployment key
if [ -z "$GIT_KEY" ]; then
  echo Unable to git ssh, missing environment variables
  exit 2
fi

GITHUB_FINGERPRINT=SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8

echo Addding github.com to known_hosts
mkdir -p /root/.ssh
touch /root/.ssh/known_hosts
ssh-keyscan -H github.com >> /root/.ssh/known_hosts
chmod 600 /root/.ssh/known_hosts

echo Validating good known_hosts
ssh-keygen -l -f ~/.ssh/known_hosts | grep $GITHUB_FINGERPRINT

echo Starting ssh-agent
eval "$(ssh-agent -s)"

echo Loading github key
echo $GIT_KEY | sed -E 's/([^ ]{40,64}) /*\1*/g' | tr "*" "\n" | sed '/^$/d' > /tmp/git_key
chmod 600 /tmp/git_key
ssh-keygen -y -f /tmp/git_key > /tmp/git_key.pub
ssh-keygen -l -f /tmp/git_key.pub
ssh-add /tmp/git_key
rm /tmp/git_key

echo Setting up secrets
GIT_PATH=`git remote -v | grep fetch | sed 's/ (fetch)//' | cut -d'/' -f4-5`
git remote set-url --push origin git@github.com:$GIT_PATH
git remote -v

echo Setting global username/email
git config --global user.email "dev-null@screwdriver.cd"
git config --global user.name "sd-buildbot"
