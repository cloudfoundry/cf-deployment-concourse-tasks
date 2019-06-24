FROM ubuntu:bionic

ENV JQ_VERSION 1.5

ENV JQ_CHECKSUM d8e36831c3c94bb58be34dd544f44a6c6cb88568

ENV go_version 1.12.6
ENV cf_cli_version 6.43.0
ENV bosh_cli_version 5.5.1
ENV bbl_version 8.1.0
ENV terraform_version 0.12.3
ENV credhub_cli_version 2.5.1
ENV git_crypt_version 0.6.0

RUN \
  apt-get update && \
  apt-get -y install \
    apt-utils \
    build-essential \
    git \
    libreadline7 \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    netcat-openbsd \
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
    ruby2.5 \
    ruby2.5-dev && \
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

# git-crypt
RUN \
  wget https://github.com/AGWA/git-crypt/archive/${git_crypt_version}.tar.gz -O /tmp/git-crypt.tar.gz && \
  tar xzvf /tmp/git-crypt.tar.gz -C /tmp && \
  cd /tmp/git-crypt-${git_crypt_version} && \
  make PREFIX=/usr/local install && \
  rm -rf /tmp/*

ENV GOPATH /go
ENV PATH /go/bin:/usr/local/go/bin:$PATH
RUN \
  wget https://golang.org/dl/go${go_version}.linux-amd64.tar.gz -P /tmp && \
  tar xzvf /tmp/go${go_version}.linux-amd64.tar.gz -C /usr/local && \
  mkdir ${GOPATH} && \
  rm -rf /tmp/*

# Log Cache CLI
RUN go get -u code.cloudfoundry.org/log-cache-cli/cmd/cf-lc-plugin && \
    cf install-plugin ${GOPATH}/bin/cf-lc-plugin -f

RUN go get -u github.com/cloudfoundry/uptimer && \
  go get -u github.com/onsi/ginkgo/... && \
  cd ${GOPATH}/src/github.com/cloudfoundry/uptimer && \
    ginkgo -r -randomizeSuites -randomizeAllSpecs && \
  cd -
