#!/bin/bash

set -ex

IMAGE_NAME="adityacprtm/gke-deployment"
TAG="${1}"

REGISTRY="docker.io"

docker build -t ${REGISTRY}/${IMAGE_NAME}:${TAG} -t ${REGISTRY}/${IMAGE_NAME}:latest .
docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}
docker push ${REGISTRY}/${IMAGE_NAME}:latest
