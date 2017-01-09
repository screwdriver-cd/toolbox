#!/bin/bash -ev

IMAGE=$1
VERSION=$2
TYPE=$3

docker pull screwdrivercd/$IMAGE:$VERSION
docker tag screwdrivercd/$IMAGE:$VERSION screwdrivercd/$IMAGE:$TYPE
docker push screwdrivercd/$IMAGE:$TYPE
