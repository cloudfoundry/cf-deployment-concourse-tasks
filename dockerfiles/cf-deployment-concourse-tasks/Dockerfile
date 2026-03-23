FROM golang:1.26.1-bookworm

ENV log_cache_cli_version=6.2.1
ENV terraform_version=1.14.7
ENV uptimer_version=15815b429925dcd7664a2a96608ba3ccf54b74f8
ENV yq_version=4.52.4

RUN apt-get update

# useful utils
RUN set -eux; \
      apt-get -y install \
        git-crypt \
        gnupg \
        jq \
        netcat-openbsd \
        unzip \
        vim \
        wget

# ruby
RUN set -eux; \
      apt-get -y install ruby-full; \
      ruby --version | grep 3\.1

# yq
RUN set -eux; \
      url="https://github.com/mikefarah/yq/releases/download/v${yq_version}/yq_linux_amd64"; \
      wget "${url}" -O /usr/local/bin/yq; \
      chmod +x /usr/local/bin/yq; \
      yq --version

# setup CloudFoundry APT repo
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
      wget -q -O - https://raw.githubusercontent.com/cloudfoundry/bosh-apt-resources/master/public.key \
        | gpg --dearmor \
        | tee /usr/share/keyrings/cloudfoundry.gpg > /dev/null; \
      echo "deb [signed-by=/usr/share/keyrings/cloudfoundry.gpg] http://apt.ci.cloudfoundry.org stable main" \
        | tee /etc/apt/sources.list.d/cloudfoundry.list; \
      apt-get update


# bosh-cli
RUN set -eux; \
      apt-get install -y bosh-cli; \
      bosh --version

# bosh-bootloader (bbl)
RUN set -eux; \
      apt-get install -y bosh-bootloader; \
      bbl version

# cf-cli
RUN set -eux; \
      apt-get install -y cf-cli; \
      cf version

# credhub-cli
RUN set -eux; \
      apt-get install -y credhub-cli; \
      credhub --version

# uaa-cli
RUN set -eux; \
      apt-get install -y uaa-cli; \
      uaa version

# terraform (not in apt repo - download from HashiCorp)
RUN set -eux; \
      mkdir -p /tmp/terraform; \
      url="https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"; \
      wget "${url}" -O /tmp/terraform/terraform.zip; \
      unzip /tmp/terraform/terraform.zip -d /tmp/terraform; \
      mv /tmp/terraform/terraform /usr/local/bin; \
      chmod +x /usr/local/bin/terraform; \
      terraform version; \
      rm -rf /tmp/terraform

# log-cache (not in apt repo - install as CF plugin)
RUN set -eux; \
      url="https://github.com/cloudfoundry/log-cache-cli/releases/download/v${log_cache_cli_version}/log-cache-cf-plugin_${log_cache_cli_version}_linux_amd64"; \
      wget "${url}" -O /tmp/log-cache-plugin; \
      cf install-plugin /tmp/log-cache-plugin -f; \
      rm /tmp/log-cache-plugin

# uptimer (built from source via Go)
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


