FROM golang:1.20.5-buster

ENV JQ_VERSION 1.6
ENV JQ_CHECKSUM 056ba5d6bbc617c29d37158ce11fd5a443093949

ENV cf_cli_version 8.6.1
ENV bosh_cli_version 7.2.3
ENV bbl_version 9.0.4
ENV terraform_version 1.4.6
ENV credhub_cli_version 2.9.16
ENV git_crypt_version 0.7.0
ENV log_cache_cli_version 5.0.1
ENV uptimer_version 5b8d89bf828c6d7011abf2673b7b5e24d5bd918b

RUN set -eux; \
      apt-get update; \
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
        zlibc; \
      apt-get -y install ruby-full; \
      apt-get remove -y --purge software-properties-common

# assert ruby 2.5 is installed
RUN ruby --version | grep 2\.5

# jq
RUN set -eux; \
      url="https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64"; \
      wget -O /usr/local/bin/jq "${url}"; \
      echo "${JQ_CHECKSUM} /usr/local/bin/jq" | sha1sum -c -; \
      chmod +x /usr/local/bin/jq

# yq
RUN pip3 install yq

# bosh
RUN set -eux; \
      url="https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64"; \
      wget -O /usr/local/bin/bosh "${url}"; \
      chmod +x /usr/local/bin/bosh; \
      bosh --version

# cf
RUN set -eux; \
      url="https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${cf_cli_version}"; \
      wget -O cf.tgz "${url}"; \
      mkdir /tmp/cf; \
      tar -C /tmp/cf -xzf cf.tgz; \
      rm cf.tgz; \
      mv /tmp/cf/cf8 /usr/local/bin/cf; \
      rm -r /tmp/cf; \
      chmod +x /usr/local/bin/cf; \
      cf version

# credhub
RUN set -eux; \
      url="https://github.com/cloudfoundry/credhub-cli/releases/download/${credhub_cli_version}/credhub-linux-${credhub_cli_version}.tgz"; \
      wget -O credhub.tgz "${url}"; \
      tar -C /usr/local/bin -xzf credhub.tgz; \
      rm credhub.tgz; \
      chmod +x /usr/local/bin/credhub; \
      credhub --version

# bbl
RUN set -eux; \
      url="https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_x86-64"; \
      wget -O /usr/local/bin/bbl "${url}"; \
      chmod +x /usr/local/bin/bbl; \
      bbl version

RUN \
      wget https://github.com/cloudfoundry/bosh-bootloader/archive/v${bbl_version}.tar.gz -P /tmp && \
      mkdir -p /var/repos/bosh-bootloader && \
      tar xvf  /tmp/v${bbl_version}.tar.gz --strip-components=1 -C /var/repos/bosh-bootloader && \
      rm -rf /tmp/*

# terraform
RUN set -eux; \
      file="terraform_${terraform_version}_linux_amd64.zip"; \
      url="https://releases.hashicorp.com/terraform/${terraform_version}/${file}"; \
      sha256="$(curl "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_SHA256SUMS" | grep linux_amd64)"; \
      wget -O "${file}" "${url}"; \
      echo "${sha256}" | shasum -c -; \
      unzip "${file}" -d /usr/local/bin; \
      rm "${file}"; \
      chmod +x /usr/local/bin/terraform; \
      terraform version

# git-crypt
RUN set -eux; \
      url="https://github.com/AGWA/git-crypt/releases/download/${git_crypt_version}/git-crypt-${git_crypt_version}-linux-x86_64"; \
      wget -O /usr/local/bin/git-crypt "${url}"; \
      chmod +x /usr/local/bin/git-crypt

# log-cache
RUN set -eux; \
      url="https://github.com/cloudfoundry/log-cache-cli/releases/download/v${log_cache_cli_version}/log-cache-cf-plugin-linux"; \
      wget -O log-cache-plugin "${url}"; \
      cf install-plugin log-cache-plugin -f; \
      rm log-cache-plugin

# uptimer
RUN go install "github.com/cloudfoundry/uptimer@${uptimer_version}"

# Add trusted relint ca certificate
ARG RELINT_CA_CERTIFICATE
ARG PREVIOUS_RELINT_CA_CERTIFICATE
RUN echo -n "$RELINT_CA_CERTIFICATE" > /usr/local/share/ca-certificates/relint.crt && \
    echo -n "$PREVIOUS_RELINT_CA_CERTIFICATE" > /usr/local/share/ca-certificates/previous_relint.crt && \
  /usr/sbin/update-ca-certificates -f
