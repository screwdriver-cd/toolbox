#!/bin/bash -e
# DOCKER_TRIGGER = API Key for triggering Docker Hub
# DOCKER_TAG = Tag to check for
# DOCKER_REPO = Org/Repo name
if [ -z "$DOCKER_TRIGGER" ] || [ -z "$DOCKER_REPO" ] || [ -z "$DOCKER_TAG" ]; then
  echo Unable to docker trigger, missing environment variables
  exit 2
fi

DOCKER_URL=https://registry.hub.docker.com/u/${DOCKER_REPO}/trigger/${DOCKER_TRIGGER}/
# Latest
curl -H "Content-Type: application/json" --data '{"docker_tag": "master"}' -X POST $DOCKER_URL
# Recent Tag
curl -H "Content-Type: application/json" --data "{\"source_type\": \"Tag\", \"source_name\": \"${DOCKER_TAG}\"}" -X POST $DOCKER_URL
