#!/bin/bash -e
# K8S_HOST = Kubernetes Hostname
# K8S_TOKEN = Kubernetes Service Account Token
# K8S_DEPLOYMENT = Kubernetes Deployment Name
# K8S_CONTAINER = Container name to update in deployment
# K8S_IMAGE = Docker image name (without the version)
# K8S_TAG = Docker tag to install
# K8S_ENV_KEY = Environment key to update (optional)
# K8S_ENV_VALUE = Environment value to update (optional)
if [ -z "$K8S_TOKEN" ] || [ -z "$K8S_TAG" ] || [ -z "$K8S_DEPLOYMENT" ] || [ -z "$K8S_CONTAINER" ] || [ -z "$K8S_IMAGE" ] || [ -z "$K8S_HOST" ]; then
  echo Unable to kubernetes trigger, missing environment variables
  exit 2
fi

if [ ! -z "$K8S_ENV_KEY" ] && [ ! -z "$K8S_ENV_VALUE" ]; then
  echo Overriding an Environment key ${K8S_ENV_KEY} with ${K8S_ENV_VALUE}
  ENVIRO_MOD=",\"env\":[{\"name\":\"${K8S_ENV_KEY}\",\"value\":\"${K8S_ENV_VALUE}\"}]"
fi

echo "Triggering Kubernetes deployment"
URL=https://${K8S_HOST}/apis/extensions/v1beta1/namespaces/default/deployments/${K8S_DEPLOYMENT}
BODY="{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"${K8S_CONTAINER}\",\"image\":\"${K8S_IMAGE}:${K8S_TAG}\"${ENVIRO_MOD}}]}}}}"
curl -k -i \
  -XPATCH \
  -H "Accept: application/json, */*" \
  -H "Authorization: Bearer ${K8S_TOKEN}" \
  -H "Content-Type: application/strategic-merge-patch+json" \
  -d $BODY \
  $URL > /tmp/k8s_out
grep "200 OK" /tmp/k8s_out || (echo "Failed deployment" && cat /tmp/k8s_out && exit 1)
