FROM ubuntu:trusty

ENV HOME /root

RUN \
  apt-get update && \
  apt-get -y install \
    git \
    jq \
    wget

RUN \
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-0.0.147-linux-amd64 --output-document="/usr/bin/bosh" && \
  cd /usr/bin && \
  echo "533342d7663c3e5dc731769e157608c74dd9eccb bosh" | sha1sum -c - && \
  chmod +x bosh

RUN \
  wget "$(wget -qO- https://api.github.com/repos/cloudfoundry/bosh-bootloader/releases | jq -r .[0].assets[].browser_download_url | grep _linux)" && \
  mv bbl-* /usr/local/bin/bbl && \
  chmod +x /usr/local/bin/bbl
