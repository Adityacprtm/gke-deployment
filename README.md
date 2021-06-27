# GKE-Deployment

![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/adityacprtm/gke-deployment)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/adityacprtm/gke-deployment)

A container to support K8s deployment on GKE

## Inside

| Tools            | Version |
| ---------------- | ------- |
| git              | 2.32.0  |
| python           | 3.9.5   |
| Google Cloud SDK | 346.0.0 |
| helm             | v3.6.1  |
| consul-template  | v0.26.0 |
| validtoml        | latest  |

## Build

```bash
chmod +x build-push.sh
./build-push.sh <TAG_VERSION>
```

## Usage

```bash
docker run -v /home/user/.config/gcloud:/root/.config/gcloud -v /home/user/dev/lion/.kube:/root/.kube --rm -it adityacprtm/gke-deployment:latest bash

# jenkins
docker.image('adityacprtm/gke-deployment').inside('-v /home/user/.config/gcloud:/root/.config/gcloud -v /home/user/.kube:/root/.kube'){
    # do something
}
```

> You can also mount like `.ssh`, `.consul-template` config and `hosts`.
