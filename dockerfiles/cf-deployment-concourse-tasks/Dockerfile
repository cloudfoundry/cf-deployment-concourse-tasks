FROM golang:1.21.11-bullseye

ENV bbl_version 9.0.22
ENV bosh_cli_version 7.6.1
ENV cf_cli_version 8.7.10
ENV credhub_cli_version 2.9.31
ENV log_cache_cli_version 6.0.1
ENV terraform_version 1.8.5
ENV uptimer_version 7c0347b27ab33e45c01670d5223c69ea566d1e56
ENV yq_version 4.44.2

RUN apt-get update

# useful utils
RUN set -eux; \
      apt-get -y install \
        git-crypt \
        jq \
        netcat-openbsd \
        unzip \
        vim;

# ruby
RUN set -eux; \
      apt-get -y install ruby-full; \
      ruby --version | grep 2\.7

# yq
RUN set -eux; \
      url="https://github.com/mikefarah/yq/releases/download/v${yq_version}/yq_linux_amd64"; \
      wget "${url}" -O /usr/local/bin/yq; \
      chmod +x /usr/local/bin/yq; \
      yq --version

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
        sqlite3 \
        zlib1g-dev; \
      url="https://github.com/cloudfoundry/bosh-cli/releases/download/v${bosh_cli_version}/bosh-cli-${bosh_cli_version}-linux-amd64"; \
      wget "${url}" -O /usr/local/bin/bosh; \
      chmod +x /usr/local/bin/bosh; \
      bosh --version

# cf
RUN set -eux; \
      mkdir -p /tmp/cf; \
      url="https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${cf_cli_version}"; \
      wget "${url}" -O /tmp/cf/cf.tgz; \
      tar -xzf /tmp/cf/cf.tgz -C /tmp/cf; \
      mv /tmp/cf/cf8 /usr/local/bin/cf; \
      chmod +x /usr/local/bin/cf; \
      cf version; \
      rm -rf /tmp/cf

# credhub
RUN set -eux; \
      mkdir -p /tmp/credhub; \
      url="https://github.com/cloudfoundry/credhub-cli/releases/download/${credhub_cli_version}/credhub-linux-amd64-${credhub_cli_version}.tgz"; \
      wget "${url}" -O /tmp/credhub/credhub.tgz; \
      tar -xzf /tmp/credhub/credhub.tgz -C /tmp/credhub; \
      mv /tmp/credhub/credhub /usr/local/bin; \
      chmod +x /usr/local/bin/credhub; \
      credhub --version; \
      rm -rf /tmp/credhub

# bbl
RUN set -eux; \
      url="https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_amd64"; \
      wget "${url}" -O /usr/local/bin/bbl; \
      chmod +x /usr/local/bin/bbl; \
      bbl version

# terraform
RUN set -eux; \
      mkdir -p /tmp/terraform; \
      url="https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"; \
      wget "${url}" -O /tmp/terraform/terraform.zip; \
      unzip /tmp/terraform/terraform.zip -d /tmp/terraform; \
      mv /tmp/terraform/terraform /usr/local/bin; \
      chmod +x /usr/local/bin/terraform; \
      terraform version; \
      rm -rf /tmp/terraform

# log-cache
RUN set -eux; \
      url="https://github.com/cloudfoundry/log-cache-cli/releases/download/v${log_cache_cli_version}/log-cache-cf-plugin-linux"; \
      wget "${url}" -O /tmp/log-cache-plugin; \
      cf install-plugin /tmp/log-cache-plugin -f; \
      rm /tmp/log-cache-plugin

# uptimer
RUN set -eux; \
      go install "github.com/cloudfoundry/uptimer@${uptimer_version}"; \
      uptimer -v

# Add trusted relint ca certificate
ARG RELINT_CA_CERTIFICATE
ARG PREVIOUS_RELINT_CA_CERTIFICATE
RUN set -e; \
      echo -n "$RELINT_CA_CERTIFICATE" > /usr/local/share/ca-certificates/relint.crt; \
      echo -n "$PREVIOUS_RELINT_CA_CERTIFICATE" > /usr/local/share/ca-certificates/previous_relint.crt; \
      /usr/sbin/update-ca-certificates -f
