# Toolbox
Central repository for handy Screwdriver-related scripts and other tools

## Recreate all pipelines
This script will create all pipelines and their corresponding secrets, except for the `GIT_KEY`s. Those will need to be created manually.

1. Put all secrets into the `.secrets_config.json` file.
1. Run
```bash
$ npm install request
$ node mass-create-pipelines.js
```

## Re-tag Docker Images
Makes it easy to retag specific docker images as stable

```bash
$ ./docker-tag.sh ui v1.0.4 stable
```

## Code Coverage
Automatically uploads the code coverage to Coveralls inside a Screwdriver build.  Requires npm module coveralls.

```bash
$ npm install coveralls
$ ./coverage.sh
```

## Trigger Docker Build
Tickles the Docker Hub webhook to start a build for master and a specified tag.

```bash
$ export DOCKER_TRIGGER="webhook API key"
$ export DOCKER_REPO="screwdrivercd/screwdriver"
$ export DOCKER_TAG="v1.2.3"
$ ./docker-trigger.sh
```

##  Wait for Docker Hub Build
Waits until a Git tag is finished building on Docker Hub.

```bash
$ export DOCKER_REPO="screwdrivercd/screwdriver"
$ export DOCKER_TAG="v1.2.3"
$ ./docker-wait.sh
```

## Get Latest Tag
Checks the Git tags for the latest version and writes it to a file.

*requires either Linux or Screwdriver build environment to run*

```bash
$ ./git-latest.sh
$ cat VERSION
v1.2.3
```
