#!/bin/bash -e
# DOCKER_TAG = Tag to check for
# DOCKER_REPO = Org/Repo name
if [ -z "$DOCKER_TAG" ] || [ -z "$DOCKER_REPO" ]; then
  echo Unable to docker wait, missing environment variables
  exit 2
fi

function check_status {
  TOKEN=`wget -q -O - "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$DOCKER_REPO:pull" | python -c "import sys, json; print(json.load(sys.stdin))['token']"`
  wget -S --spider -q --header="Authorization: Bearer $TOKEN" https://index.docker.io/v2/$DOCKER_REPO/manifests/$DOCKER_TAG > /dev/null 2>&1
}

echo Looking for image $DOCKER_REPO:$DOCKER_TAG

MINUTES=0
until check_status
do
  if [ $MINUTES -gt 35 ] ; then
    echo "Timed out after 35 minutes"
    exit 1
  fi

  echo "Not available yet ($MINUTES minutes elapsed)"
  sleep 60
  ((MINUTES+=1))
done
echo Image found
