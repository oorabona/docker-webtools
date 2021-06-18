ARG BASE_IMAGE="buster"

# Kudos for this hack go to : https://stackoverflow.com/questions/43473236/docker-build-arg-and-copy/43473956
FROM golang:${BASE_IMAGE} AS golang-base

FROM ruby:2-${BASE_IMAGE} AS ruby-base

FROM debian:${BASE_IMAGE}

ARG PACKAGES_VERSIONS_FILE="versions.vars"

WORKDIR /tmp

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y install \
     apache2-utils \
     nodejs \
     npm \
     build-essential \
     autoconf \
     libtool \
     automake \
     git \
     libc-dev \
     linux-headers-4.19.0-16-all \
     libc-ares-dev \
     libcurl4 \
     ruby-dev \
     libffi-dev \
     procps \
     libsqlite3-dev \
     perl-base \
     libnet-ssleay-perl \
     openssl \
     luajit \
     luajit-5.1-dev \
     lua5.1 \
     liblua5.1-dev \
     curl \
     libcurl4-openssl-dev \
     zlib1g \
     zlib1g-dev \
     python3 \
     python3-pip \
  && if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python ; fi \
  && pip3 install --no-cache --upgrade pip setuptools wheel \
  && if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip ; fi \
  && echo "install: --no-document --no-post-install-message\nupdate: --no-document --no-post-install-message" > /etc/gemrc

COPY helpers/ /usr/local/bin
COPY ${PACKAGES_VERSIONS_FILE} /etc

# Projects to compile from source
RUN  get-package wg wrk \
  && cd wg-wrk* \
  && sed -i '34s#$#/luajit-2.1#' Makefile \
  && make WITH_LUAJIT=/usr WITH_OPENSSL=/usr \
  && cp wrk /usr/local/bin \
  && rm -rf /tmp/*

RUN  get-package JoeDog siege \
  && cd JoeDog-siege* \
  && utils/bootstrap \
  && export CFLAGS="-UPAGESIZE" \
  && ./configure \
  && make && make install \
  && rm -rf /tmp/*

# Disabled for now (seems to break curl-loader eventually)
# RUN  curl -sSL https://sourceforge.net/projects/axtls/files/2.1.5/axTLS-2.1.5.tar.gz/download | tar zxvf - \
#   && cd /tmp/axtls-code \
#   && curl -sfSL https://gist.githubusercontent.com/oorabona/421f38bb4cf6174d38b4b3cfb08eaa0c/raw/ac6ceecb2dab79b524653fcc91445d153dd5bb0c/axtls-config -o .config \
#   && cp .config config/.config \
#   && curl -sfSL https://gist.githubusercontent.com/oorabona/421f38bb4cf6174d38b4b3cfb08eaa0c/raw/1f83243ac8f1993274701deb1d43106518c60556/axtls-config.h -o config/config.h \
#   && make \
#   && make install \
#   && ldconfig \
#   && rm -rf /tmp/*

RUN  curl -sSL https://sourceforge.net/projects/curl-loader/files/latest/download | tar -jxf - \
  && cd /tmp/curl-loader-0.56 \
  && make debug=0 optimize=1 \
  && make install \
  && rm -rf /tmp/*

RUN  get-package httperf httperf \
  && cd httperf* \
  && autoreconf -i \
  && autoconf \
  && libtoolize --force \
  && automake --add-missing \
  && ./configure \
  && make \
  && make install \
  && rm -rf /tmp/*

RUN  curl -fSL http://sourceforge.net/projects/dirb/files/dirb/2.22/dirb222.tar.gz/download | tar -zxvf - \
  && cd dirb* \
  && export CFLAGS=-fcommon \
  && chmod +x configure && ./configure \
  && make && make install \
  && cd .. \
  && rm -rf dirb*

# NPM packages
RUN  npm i autocannon -g \
  && rm -rf /root/.npm

# Ruby based packages
# don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"

COPY --from=ruby-base /usr/local/lib/ /usr/local/lib/
COPY --from=ruby-base /usr/local/bin/ /usr/local/bin/
COPY --from=ruby-base /usr/local/include/ /usr/local/include/

RUN  get-package urbanadventurer WhatWeb \
  && cd urbanadventurer-WhatWeb* \
  && make install \
  && cd .. \
  && rm -rf urbanadventurer-WhatWeb* \
  && rm -rf /root/.bundle

COPY --from=wpscanteam/wpscan /usr/local/bundle/bin/ /usr/local/bundle/bin/
COPY --from=wpscanteam/wpscan /usr/local/bundle /usr/local/bundle

RUN  gem pristine ffi --version 1.15.3 \
  && gem pristine nokogiri --version 1.11.7 \
  && gem pristine yajl-ruby --version 1.4.1 \
  && gem pristine racc --version 1.5.2

RUN /usr/local/bundle/bin/wpscan --update --verbose

# Go packages
COPY --from=golang-base /usr/local/go/ /usr/local/go/

ENV GOPATH=/go
ENV PATH=$PATH:/go/bin:/usr/local/go/bin
RUN  go get github.com/nakabonne/ali \
  && go get github.com/cmpxchg16/gobench \
  && rm -rf /go/pkg /root/.cache

# Packages not requiring any compilation
RUN  get-package sullo nikto \
  && cd sullo-nikto* \
  && mv program /nikto \
  && rm -rf /tmp/*

RUN  get-package sqlmapproject sqlmap \
  && mv sqlmap* /sqlmap

ENV PATH=$PATH:/nikto:/sqlmap
