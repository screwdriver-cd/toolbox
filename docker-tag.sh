#!/bin/bash -e

IMAGE=$1
VERSION=$2
TYPE=$3
if [ -z "$IMAGE" ] || [ -z "$VERSION" ] || [ -z "$TYPE" ]; then
  echo Usage: ./docker-tag IMAGE OLDTAG NEWTAG
  exit 2
fi

docker buildx imagetools create -t screwdrivercd/$IMAGE:$TYPE screwdrivercd/$IMAGE:$VERSION
