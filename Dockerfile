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
  && apk add --update --no-cache curl ca-certificates bash python3 git openssl openssh docker-cli \
  && mkdir /root/.docker \
  && mkdir /root/.kube \
  && mkdir /root/.ssh \
  && touch /root/.ssh/id_rsa \
  && chmod 600 /root/.ssh/id_rsa \
  && ssh-keyscan -t rsa github.com | tee /root/.ssh/known_hosts | ssh-keygen -lf - \
  && rm -rf /var/lib/apk/lists/* \
  && rm -rf /var/cache/apk/*
SHELL   [ "/bin/bash", "-c" ]
# gcloud
ENV     GCLOUD_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-366.0.0-linux-x86_64.tar.gz
RUN     curl -sSfL ${GCLOUD_URL} | tar xvz \
  && ./google-cloud-sdk/install.sh -q \
  && source /google-cloud-sdk/completion.bash.inc \
  && source /google-cloud-sdk/path.bash.inc \
  && echo "source /google-cloud-sdk/completion.bash.inc" >> ~/.bashrc \
  && echo "source /google-cloud-sdk/path.bash.inc" >> ~/.bashrc
ENV     PATH=/google-cloud-sdk/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# kubectl
RUN     curl -sSfLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin
# helm
RUN     curl -sSfL https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz | tar xvz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && rm -rf linux-amd64
# consul-template
RUN     wget https://releases.hashicorp.com/consul-template/0.27.1/consul-template_0.27.1_linux_amd64.zip \
  && unzip consul-template_0.27.1_linux_amd64.zip \
  && mv consul-template /usr/local/bin \
  && rm -rf consul-template_0.27.1_linux_amd64.zip
# dotenv-linter
RUN     curl -sSfL --connect-timeout 5 --retry 5 --retry-delay 0 --retry-max-time 40 \ 
  https://raw.githubusercontent.com/dotenv-linter/dotenv-linter/master/install.sh | sh -s -- -b /usr/local/bin v3.1.0 \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*
# validtoml
COPY    --from=0 /go/src/github.com/adityacprtm/validtoml/validtoml /usr/local/bin