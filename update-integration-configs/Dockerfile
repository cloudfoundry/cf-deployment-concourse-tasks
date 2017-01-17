FROM ubuntu:trusty

ENV HOME /root

RUN \
  apt-get update && \
  apt-get -y install \
    git \
    wget

RUN \
  wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 --output-document="/usr/bin/jq" && \
  cd /usr/bin && \
  echo "d8e36831c3c94bb58be34dd544f44a6c6cb88568 jq" | sha1sum -c - && \
  chmod +x jq

RUN \
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-0.0.147-linux-amd64 --output-document="/usr/bin/bosh" && \
  cd /usr/bin && \
  echo "533342d7663c3e5dc731769e157608c74dd9eccb bosh" | sha1sum -c - && \
  chmod +x bosh
