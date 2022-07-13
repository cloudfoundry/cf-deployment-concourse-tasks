FROM golang:1.18-buster

ENV JQ_VERSION 1.6
ENV JQ_CHECKSUM 056ba5d6bbc617c29d37158ce11fd5a443093949

ENV cf_cli_version 8.4.0
ENV bosh_cli_version 7.0.1
ENV bbl_version 8.4.93
ENV terraform_version 1.2.5
ENV credhub_cli_version 2.9.3
ENV git_crypt_version 0.6.0
ENV log_cache_cli_version 4.0.6
ENV uptimer_version 1d582df0c466e91f7f0874da0f79e5b03677a865

RUN \
  apt-get update && \
  apt-get -y install \
    apt-utils \
    build-essential \
    curl \
    git \
    libreadline6-dev \
    libreadline7 \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    netcat-openbsd \
    openssl \
    python3-pip \
    software-properties-common \
    sqlite \
    unzip \
    vim \
    wget \
    zlib1g-dev \
    zlibc && \
  apt-get -y install \
    ruby-full && \
  apt-get remove -y --purge software-properties-common

# assert ruby 2.5 is installed
RUN ruby --version | grep 2\.5

# jq
RUN \
  wget https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 --output-document="/usr/bin/jq" && \
  cd /usr/bin && \
  echo "${JQ_CHECKSUM} jq" | sha1sum -c - && \
  chmod +x jq

# yq
RUN \
  pip3 install yq

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

# Log Cache CLI
RUN \
  wget https://github.com/cloudfoundry/log-cache-cli/releases/download/v${log_cache_cli_version}/log-cache-cf-plugin-linux -P /tmp && \
  cf install-plugin /tmp/log-cache-cf-plugin-linux -f

RUN \
  go install github.com/cloudfoundry/uptimer@${uptimer_version} && \
  go install github.com/onsi/ginkgo/ginkgo@latest

# Add trusted relint ca certificate
ARG RELINT_CA_CERTIFICATE
ARG PREVIOUS_RELINT_CA_CERTIFICATE
RUN echo -n "$RELINT_CA_CERTIFICATE" > /usr/local/share/ca-certificates/relint.crt && \
    echo -n "$PREVIOUS_RELINT_CA_CERTIFICATE" > /usr/local/share/ca-certificates/previous_relint.crt && \
  /usr/sbin/update-ca-certificates -f
