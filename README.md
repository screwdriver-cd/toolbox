# toolbox
Central repository for handy Screwdriver-related scripts and other tools

## To recreate all pipelines:
This script will create all pipelines and their corresponding secrets, except for the `GIT_KEY`s. Those will need to be created manually.

1. Put all secrets into the `.secrets_config.json` file.
1. Run
```javascript
$ npm install
$ node mass-create-pipelines.js
```

## To tag stable image:
Run `stable.sh`. For example, to retag latest UI as stable:

```
./stable.sh ui latest stable
```
