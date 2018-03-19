FROM ubuntu:trusty

ENV GO_VERSION 1.9
ENV JQ_VERSION 1.5

ENV JQ_CHECKSUM d8e36831c3c94bb58be34dd544f44a6c6cb88568

ENV cf_cli_version 6.35.2
ENV bosh_cli_version 3.0.1
ENV bbl_version 6.4.4
ENV terraform_version 0.11.4
ENV credhub_cli_version 1.7.0

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
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64 --output-document="/usr/bin/bosh" && \
  chmod +x /usr/bin/bosh

# cf-cli
RUN \
  cd /tmp && \
  wget -q -O cf.deb "https://cli.run.pivotal.io/stable?release=debian64&version=${cf_cli_version}&source=github-rel" && \
  dpkg -i cf.deb && \
  rm cf.deb

# credhub-cli
RUN \
  wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${credhub_cli_version}/credhub-linux-${credhub_cli_version}.tgz -P /tmp && \
  tar xzvf /tmp/credhub-linux-${credhub_cli_version}.tgz -C /usr/local/bin && \
  chmod +x /usr/local/bin/credhub

# bbl and dependencies
RUN \
  wget https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_x86-64 -P /tmp && \
  mv /tmp/bbl-* /usr/local/bin/bbl && \
  cd /usr/local/bin && \
  chmod +x bbl

RUN \
  wget https://github.com/cloudfoundry/bosh-bootloader/archive/v${bbl_version}.tar.gz -P /tmp && \
  mkdir -p /var/repos/bosh-bootloader && \
  tar xvf  /tmp/v${bbl_version}.tar.gz --strip-components=1 -C /var/repos/bosh-bootloader && \
  rm -rf /tmp/*

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
