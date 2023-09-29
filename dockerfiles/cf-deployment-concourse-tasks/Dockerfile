FROM golang:1.20.8-bullseye

ENV JQ_VERSION 1.6
ENV JQ_CHECKSUM 056ba5d6bbc617c29d37158ce11fd5a443093949

ENV cf_cli_version 8.7.3
ENV bosh_cli_version 7.4.0
ENV bbl_version 9.0.12
ENV terraform_version 1.5.7
ENV credhub_cli_version 2.9.21
ENV git_crypt_version 0.7.0
ENV log_cache_cli_version 5.0.4
ENV uptimer_version f5f8149b8977e030b60b5fde37e54db8af4025cc

RUN apt-get update

# utils
RUN set -eux; \
      apt-get -y install \
        netcat-openbsd \
        python3-pip \
        ruby-full \
        unzip \
        vim;

# assert ruby 2.7 is installed
RUN ruby --version | grep 2\.7

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
      apt-get -y install \
        build-essential \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        openssl \
        ruby \
        ruby-dev \
        sqlite3 \
        zlib1g-dev; \
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
      url="https://github.com/cloudfoundry/credhub-cli/releases/download/${credhub_cli_version}/credhub-linux-amd64-${credhub_cli_version}.tgz"; \
      wget -O credhub.tgz "${url}"; \
      tar -C /usr/local/bin -xzf credhub.tgz; \
      rm credhub.tgz; \
      chmod +x /usr/local/bin/credhub; \
      credhub --version

# bbl
RUN set -eux; \
      url="https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_amd64"; \
      wget -O /usr/local/bin/bbl "${url}"; \
      chmod +x /usr/local/bin/bbl; \
      bbl version

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
