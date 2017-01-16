FROM ubuntu:trusty

RUN \
  apt-get update && \
  apt-get -y install \
    build-essential \
    curl \
    jq \
    wget

RUN \
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-0.0.124-linux-amd64 --output-document="/usr/bin/bosh" && \
  cd /usr/bin && \
  echo "5065d3c8291abab1ffef1bac6de6cea8d514e319 bosh" | sha1sum -c - && \
  chmod +x bosh

RUN \
  wget https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.91-linux-amd64 -P /tmp && \
  mv /tmp/bosh-init-0.0.91-linux-amd64 /usr/local/bin/bosh-init && \
  chmod +x /usr/local/bin/bosh-init && \
  rm -rf /tmp/*

RUN wget "$(curl -s https://api.github.com/repos/cloudfoundry/bosh-bootloader/releases | jq -r .[0].assets[].browser_download_url | grep _linux)" && \
  mv bbl-* /usr/local/bin/bbl && \
  chmod +x /usr/local/bin/bbl
