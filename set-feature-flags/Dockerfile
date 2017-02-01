FROM ubuntu:trusty

ENV HOME /root

RUN \
  apt-get update && \
  apt-get -y install \
    wget

RUN \
  wget -q -O cf.deb "https://cli.run.pivotal.io/stable?release=debian64&version=6.23.1&source=github-rel" && \
  dpkg -i cf.deb

RUN \
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-0.0.147-linux-amd64 --output-document="/usr/bin/bosh" && \
  cd /usr/bin && \
  echo "533342d7663c3e5dc731769e157608c74dd9eccb bosh" | sha1sum -c - && \
  chmod +x bosh
