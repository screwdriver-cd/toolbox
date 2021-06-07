#!/bin/bash -e
# GITHUB_TOKEN = Token for updating your git repo
# RELEASE_FILE = File to release or
# RELEASE_FILES = list of files to release (strings seperated by space)
if [ -z "$GITHUB_TOKEN" ] || [ -z "$RELEASE_FILE" ] || [ -z "$RELEASE_FILES" ]; then
  echo Unable to release, missing environment variables
  exit 2
fi

GITHUB_RELEASE=/tmp/linux-amd64-github-release
if [ ! -f "$GITHUB_RELEASE" ] ; then
  echo Downloading github-release
  wget -q -O - https://github.com/github-release/github-release/releases/latest \
     | egrep -o '/github-release/github-release/releases/download/v[0-9.]*/linux-amd64-github-release.bz2' \
     | wget --base=http://github.com/ -i - -O /tmp/linux-amd64-github-release.bz2
  bzip2 -dv /tmp/linux-amd64-github-release.bz2
  chmod +x $GITHUB_RELEASE
fi

GIT_VERSION=/tmp/gitversion
if [ ! -f "$GIT_VERSION" ] ; then
    echo Downloading gitversion
    wget -q -O - https://github.com/screwdriver-cd/gitversion/releases/latest \
       | egrep -o '/screwdriver-cd/gitversion/releases/download/v[0-9.]*/gitversion_linux_amd64' \
       | wget --base=http://github.com/ -i - -O /tmp/gitversion
    chmod +x $GIT_VERSION
fi

GIT_ORG=`git remote -v | grep fetch | sed 's/ (fetch)//' | cut -d'/' -f4`
GIT_REPO=`git remote -v | grep fetch | sed 's/ (fetch)//' | cut -d'/' -f5`
if [ -f VERSION ] ; then
  GIT_TAG=$(<VERSION)
else
  GIT_TAG=`$GIT_VERSION --prefix v show`
fi

echo "Creating release $GIT_TAG for $GIT_ORG / $GIT_REPO"

$GITHUB_RELEASE --version
$GITHUB_RELEASE release --user $GIT_ORG --repo $GIT_REPO --tag $GIT_TAG --name $GIT_TAG

if [ ! -z "$RELEASE_FILES" ];then
  files=($RELEASE_FILES) 
  for i in "${files[@]}"
  do
    if [ -f $i ];then
      $GITHUB_RELEASE upload --user $GIT_ORG --repo $GIT_REPO --tag $GIT_TAG --name $i --file $i
    else
      echo "Unable to release, file does not exist"
    fi
  done
else
  $GITHUB_RELEASE upload --user $GIT_ORG --repo $GIT_REPO --tag $GIT_TAG --name $RELEASE_FILE --file $RELEASE_FILE
fi


