FROM    golang:1.16-alpine
RUN     apk --update --no-cache add git less openssh \
    && rm -rf /var/lib/apk/lists/* \
    && rm -rf /var/cache/apk/*
WORKDIR /go/src/github.com/adityacprtm/validtoml/
RUN     git clone https://github.com/Adityacprtm/validtoml.git .
RUN     rm -rf vendor \
    && go mod tidy \
    && go mod vendor
RUN     CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o validtoml .

FROM    alpine:3.14
RUN     apk update \
    && apk add --update --no-cache curl ca-certificates bash python3 git openssl \
    && rm -rf /var/lib/apk/lists/* \
    && rm -rf /var/cache/apk/*
SHELL   [ "/bin/bash", "-c" ]
# gcloud
ENV     GCLOUD_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-346.0.0-linux-x86_64.tar.gz
RUN     curl -L ${GCLOUD_URL} | tar xvz \
    && ./google-cloud-sdk/install.sh -q \
    && source /google-cloud-sdk/completion.bash.inc \
    && source /google-cloud-sdk/path.bash.inc \
    && echo "source /google-cloud-sdk/completion.bash.inc" >> ~/.bashrc \
    && echo "source /google-cloud-sdk/path.bash.inc" >> ~/.bashrc
ENV     PATH=/google-cloud-sdk/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# kubectl
RUN     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin \
    && mkdir /root/.kube \
    && mkdir /root/.ssh
# helm
RUN     curl -L https://get.helm.sh/helm-v3.6.1-linux-amd64.tar.gz | tar xvz \
    && mv linux-amd64/helm /usr/local/bin/helm
# consul-template
RUN     wget https://releases.hashicorp.com/consul-template/0.26.0/consul-template_0.26.0_linux_amd64.zip \
    && unzip consul-template_0.26.0_linux_amd64.zip \
    && mv consul-template /usr/local/bin \
    && rm -rf consul-template_0.26.0_linux_amd64.zip \
    /tmp/* \
    /var/tmp/*
COPY    --from=0 /go/src/github.com/adityacprtm/validtoml/validtoml .