#!/bin/bash -e

IMAGE=$1
VERSION=$2
TYPE=$3
if [ -z "$IMAGE" ] || [ -z "$VERSION" ] || [ -z "$TYPE" ]; then
  echo Usage: ./docker-tag IMAGE OLDTAG NEWTAG
  exit 2
fi

docker pull screwdrivercd/$IMAGE:$VERSION
docker tag screwdrivercd/$IMAGE:$VERSION screwdrivercd/$IMAGE:$TYPE
docker push screwdrivercd/$IMAGE:$TYPE
