FROM ubuntu:trusty

ENV GO_VERSION 1.9
ENV JQ_VERSION 1.5
ENV BOSH_VERSION 2.0.42
ENV CF_CLI_VERSION 6.23.1
ENV BBL_VERSION v4.7.3

ENV JQ_CHECKSUM d8e36831c3c94bb58be34dd544f44a6c6cb88568
ENV BOSH_CHECKSUM a97b085e45a989abfcd88de77770bb6db0c8a29e
ENV CF_CLI_CHECKSUM b25260f46bf24d1e2586c1f4d67db3fdd89f0144

RUN \
  apt-get update && \
  apt-get -y install \
    build-essential \
    git \
    libreadline6 \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    openssl \
    software-properties-common \
    sqlite \
    unzip \
    wget \
    curl \
    zlib1g-dev \
    zlibc && \
  add-apt-repository ppa:brightbox/ruby-ng -y && \
  apt-get update && \
  apt-get -y install \
    ruby2.3 \
    ruby2.3-dev && \
  apt-get remove -y --purge software-properties-common

# jq
RUN \
  wget https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 --output-document="/usr/bin/jq" && \
  cd /usr/bin && \
  echo "${JQ_CHECKSUM} jq" | sha1sum -c - && \
  chmod +x jq

# bosh-cli
RUN \
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_VERSION}-linux-amd64 --output-document="/usr/bin/bosh" && \
  cd /usr/bin && \
  echo "${BOSH_CHECKSUM} bosh" | sha1sum -c - && \
  chmod +x bosh

# cf-cli
RUN \
  cd /tmp && \
  wget -q -O cf.deb "https://cli.run.pivotal.io/stable?release=debian64&version=${CF_CLI_VERSION}&source=github-rel" && \
  echo "${CF_CLI_CHECKSUM} cf.deb" | sha1sum -c - && \
  dpkg -i cf.deb && \
  rm cf.deb

# bbl and dependencies
ARG bbl_version
RUN \
  wget https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_x86-64 -P /tmp && \
  mv /tmp/bbl-* /usr/local/bin/bbl && \
  cd /usr/local/bin && \
  chmod +x bbl

ARG terraform_version
RUN \
  wget "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip" -P /tmp && \
  cd /tmp && \
  curl https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_SHA256SUMS | grep linux_amd64 | shasum -c - && \
  unzip "/tmp/terraform_${terraform_version}_linux_amd64.zip" -d /tmp && \
  mv /tmp/terraform /usr/local/bin/terraform && \
  cd /usr/local/bin && \
  chmod +x terraform && \
  rm -rf /tmp/*

ENV GOPATH /go
ENV PATH /go/bin:/usr/local/go/bin:$PATH
RUN \
  wget https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz -P /tmp && \
  tar xzvf /tmp/go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local && \
  mkdir ${GOPATH} && \
  rm -rf /tmp/*

RUN go get -u github.com/cloudfoundry/uptimer && \
  go get -u github.com/onsi/ginkgo/... && \
  cd ${GOPATH}/src/github.com/cloudfoundry/uptimer && \
    ginkgo -r -randomizeSuites -randomizeAllSpecs && \
  cd -
