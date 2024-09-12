#!/bin/bash -e
# GITHUB_TOKEN = Token for updating your git repo
# RELEASE_FILE = File to release or
# RELEASE_FILES = list of files to release (strings seperated by space)
if [ -z "$GITHUB_TOKEN" ] || ([ -z "$RELEASE_FILE" ] && [ -z "$RELEASE_FILES" ]); then
  echo Unable to release, missing environment variables
  exit 2
fi

GITHUB_RELEASE=/tmp/linux-amd64-github-release
if [ ! -f "$GITHUB_RELEASE" ] ; then
  echo Downloading github-release
  wget -q -O - https://api.github.com/repos/github-release/github-release/releases/latest \
     | egrep -o '/github-release/github-release/releases/download/v[0-9.]*/linux-amd64-github-release.bz2' \
     | wget --base=http://github.com/ -i - -O /tmp/linux-amd64-github-release.bz2
  bzip2 -dv /tmp/linux-amd64-github-release.bz2
  chmod +x $GITHUB_RELEASE
fi

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

GIT_ORG=`git remote -v | grep fetch | sed 's/ (fetch)//' | cut -d'/' -f4`
GIT_REPO=`git remote -v | grep fetch | sed 's/ (fetch)//' | cut -d'/' -f5`
if [ -f VERSION ] ; then
  GIT_TAG=$(<VERSION)
else
  GIT_TAG=`$GIT_VERSION --prefix v show`
fi

echo "Creating release $GIT_TAG for $GIT_ORG / $GIT_REPO"
$GITHUB_RELEASE --version

echo "Creating tag $GIT_TAG for $GIT_ORG / $GIT_REPO"
$GITHUB_RELEASE release --user $GIT_ORG --repo $GIT_REPO --tag $GIT_TAG --name $GIT_TAG

echo "Querying tag $GIT_TAG for $GIT_ORG / $GIT_REPO"
max_attempts=5
attempt=1
while [ $attempt -le $max_attempts ]; do
  if $GITHUB_RELEASE info --user "$GIT_ORG" --repo "$GIT_REPO" --tag "$GIT_TAG"; then
    echo "Successfully retrieved release info on attempt $attempt"
    break
  else
    echo "Attempt $attempt: Failed to query release info. Retrying in 5 seconds..."
    sleep 5
    attempt=$((attempt + 1))
  fi
done

if [ $attempt -gt $max_attempts ]; then
  echo "Failed to query release info after $max_attempts attempts. Exiting."
  exit 1
fi

if [ ! -z "$RELEASE_FILES" ];then
  files=($RELEASE_FILES)

  echo "Uploading files..."

  for i in "${files[@]}"
  do
    if [ -f $i ];then
      echo "Uploading file: $i"
      $GITHUB_RELEASE upload --user $GIT_ORG --repo $GIT_REPO --tag $GIT_TAG --name $i --file $i
    else
      echo "Unable to release, file does not exist"
    fi
  done
else
  echo "Uploading file: $RELEASE_FILE"
  $GITHUB_RELEASE upload --user $GIT_ORG --repo $GIT_REPO --tag $GIT_TAG --name $RELEASE_FILE --file $RELEASE_FILE
fi


