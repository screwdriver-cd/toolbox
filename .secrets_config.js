'use strict';

const secrets = {
    "instance": process.env.INSTANCE || "YOUR-INSTANCE",
    "jwt": process.env.JWT || "YOUR-JWT",
    "ghToken": process.env.GH_TOKEN || "YOUR-GITHUB-TOKEN",
    "npmToken": process.env.NPM_TOKEN || "YOUR-NPM-TOKEN",
    "k8sToken": process.env.K8S_TOKEN || "YOUR-K8S-TOKEN",
    "dockerTrigger": process.env.DOCKER_TRIGGER || "YOUR-DOCKER-TRIGGER",
    "coverallsRepoToken": process.env.COVERALLS_REPO_TOKEN || "YOUR-COVERALLS-REPO-TOKEN",
    "accessKey": process.env.ACCESS_KEY || "YOUR-ACCESS-KEY"
};

module.exports = secrets;
