/**
 * To run, put secrets in .secrets_config.json
 * Use the command:
 * node mass-create-pipelines.js
 */

/* eslint-disable */
'use strict';

const request = require('request');
const config = require('./.secrets_config');

const JWT = config.jwt;
const GH_TOKEN = config.ghToken; // *some Github tokens are named differently
const NPM_TOKEN = config.npmToken;
const K8S_TOKEN = config.k8sToken;
const DOCKER_TRIGGER = config.dockerTrigger;
const COVERALLS_REPO_TOKEN = config.coverallsRepoToken;
const ACCESS_KEY = config.accessKey;
const INSTANCE = config.instance || 'http://localhost:8080';

// Need NPM_TOKEN and GH_TOKEN secrets
const nodeRepos = [
    'models',
    'data-schema',
    'datastore-base',
    'datastore-sequelize',
    'scm-base',
    'scm-github',
    'scm-bitbucket',
    'config-parser',
    'store',
    'executor-k8s',
    'executor-base',
    'executor-j5s',
    'executor-docker',
    'generator-screwdriver',
    'circuit-fuses',
    'keymbinatorial',
    'eslint-config-screwdriver',
    'build-bookend'
];

// Need K8S_TOKEN and DOCKER_TRIGGER secrets + more
const muchSecretRepos = [
    'screwdriver', // K8S_TOKEN, DOCKER_TRIGGER, GIT_TOKEN, GIT_KEY, COVERALLS_REPO_TOKEN, ACCESS_KEY, NPM_TOKEN
    'ui', // K8S_TOKEN, DOCKER_TRIGGER, GITHUB_TOKEN, GIT_KEY
];

// Automate pipeline creation only
const noSecretRepos = [
    'homepage', //need only GIT_KEY
    'guide' //need only GIT_KEY
];

// Need GITHUB_TOKEN and GIT_KEY secrets
const goRepos = [
    'gitversion',
    'launcher',
    'log-service'
];

// Ignore
const notInUse = [
    'kubernetes', // no secrets, no pipeline
    'datastore-dynamodb', // no longer in use
    'hashr', // no longer in use
    'dynamic-dynamodb', // no longer in use
    'client', // not updated
    'fuji-app' // demo app
]

/**
 * Create secret for a single pipeline
 * @method createSecret
 * @param  {Object}     config
 * @param  {Object}     config.pipelineId
 * @param  {Object}     config.name
 * @param  {Object}     config.value
 * @return {Object}
 */
function createSecret(config) {
    return new Promise((resolve, reject) => {
        request({
            auth: {
                bearer: JWT
            },
            body: {
                pipelineId: config.pipelineId,
                name: config.name,
                value: config.value,
                allowInPR: false
            },
            json: true,
            method: 'POST',
            url: `${INSTANCE}/v4/secrets`
        }, (err, response) => {
            if (err) {
                reject(err);
            } else {
                resolve(response);
            }
        });
    });
}

/**
 * Create a pipeline with checkoutUrl
 * @method createPipeline
 * @param  {String}       checkoutUrl
 * @return {Object}       Resolves a pipeline object
 */
function createPipeline(checkoutUrl) {
    return new Promise((resolve, reject) => {
        request({
            auth: {
                bearer: JWT
            },
            body: {
                checkoutUrl
            },
            json: true,
            method: 'POST',
            url: `${INSTANCE}/v4/pipelines`
        }, (err, response) => {
            if (err) {
                reject(err);
            } else {
                resolve(response);
            }
        });
    });
}

/**
 * Create pipelines from an array of repo names
 * @method createPipelines
 * @param  {Array}        repos     An array of repo names
 * @return {Array}                  Resolves an array of pipeline objects
 */
function createPipelines(repos) {
    return Promise.all(repos.map(repo => createPipeline(`git@github.com:screwdriver-cd/${repo}.git`)));
}

/**
 * Create Node pipelines with NPM_TOKEN and GH_TOKEN secrets
 * @method createGoPipelines
 */
function createNodePipelines() {
    // create simple node pipelines
    return createPipelines(nodeRepos)
    // create NPM_TOKEN and GH_TOKEN
    .then(pipelines => {
        return pipelines.map(p => {
            return createSecret({
                pipelineId: p.body.id,
                name: 'NPM_TOKEN',
                value: NPM_TOKEN
            })
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'GH_TOKEN',
                value: GH_TOKEN
            }))});
    });
}

/**
 * Create Go pipelines with GITHUB_TOKEN secret
 * @method createGoPipelines
 */
function createGoPipelines() {
    // create simple Go pipelines
    return createPipelines(goRepos)
    // create GITHUB_TOKEN
    .then(pipelines => {
        return pipelines.map(p => {
            return createSecret({
                pipelineId: p.body.id,
                name: 'GITHUB_TOKEN',
                value: GH_TOKEN
            });
        })
    });
}

/**
 * Create UI pipeline with appropriate secrets
 * @method createUIPipeline
 */
function createUIPipeline() {
    // create pipelines for UI
    return createPipelines(['ui'])
    // create K8S_TOKEN and DOCKER_TRIGGER and GITHUB_TOKEN
    .then(pipelines => {
        return pipelines.map(p => {
            return createSecret({
                pipelineId: p.body.id,
                name: 'K8S_TOKEN',
                value: K8S_TOKEN
            })
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'DOCKER_TRIGGER',
                value: DOCKER_TRIGGER
            }))
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'GITHUB_TOKEN',
                value: GH_TOKEN
            }))
        });
    });
}

/**
 * Create API pipeline with appropriate secrets
 * @method createAPIPipeline
 */
function createAPIPipeline() {
    // create pipelines for UI
    return createPipelines(['screwdriver'])
    // create secrets
    .then(pipelines => {
        return pipelines.map(p => {
            return createSecret({
                pipelineId: p.body.id,
                name: 'K8S_TOKEN',
                value: K8S_TOKEN
            })
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'DOCKER_TRIGGER',
                value: DOCKER_TRIGGER
            }))
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'GIT_TOKEN',
                value: GH_TOKEN
            }))
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'COVERALLS_REPO_TOKEN',
                value: COVERALLS_REPO_TOKEN
            }))
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'ACCESS_KEY',
                value: ACCESS_KEY
            }))
            .then(() => createSecret({
                pipelineId: p.body.id,
                name: 'NPM_TOKEN',
                value: NPM_TOKEN
            }))
        });
    });
}

/**
 * Create all pipelines and secrets
 * @method main
 * @return Promise
 */
function main () {
    if (!JWT) { throw new Error('No JWT set'); }

    return Promise.all([
        createNodePipelines(),
        createGoPipelines(),
        createPipelines(noSecretRepos), // create pipelines only
        createAPIPipeline(),
        createUIPipeline()
    ]);
}


main();
