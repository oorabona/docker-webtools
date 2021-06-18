ARG BASE_IMAGE="latest"

FROM alpine:${BASE_IMAGE}

ARG PACKAGES_VERSIONS_FILE="versions.vars"

WORKDIR /tmp

RUN apk add --no-cache \
     apache2-utils \
     nodejs \
     npm \
     build-base \
     autoconf \
     libtool \
     automake \
     git \
     libgcc \
     libc-dev \
     linux-headers \
     libcurl \
     ruby-dev \
     libffi-dev \
     procps \
     sqlite-dev \
     perl \
     perl-net-ssleay \
     openssl \
     openssl-dev \
     luajit \
     luajit-dev \
     lua \
     lua-dev \
     curl \
     curl-dev \
     libnsl \
     libnsl-dev \
     zlib \
     zlib-dev \
     python3 \
  && ln -s /usr/include/linux/types.h /usr/include/bits/types.h \
  && if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python ; fi \
  && python3 -m ensurepip \
  && rm -r /usr/lib/python*/ensurepip \
  && pip3 install --no-cache --upgrade pip setuptools wheel \
  && if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip ; fi \
  && echo "install: --no-document --no-post-install-message\nupdate: --no-document --no-post-install-message" > /etc/gemrc

COPY helpers/ /usr/local/bin
COPY ${PACKAGES_VERSIONS_FILE} /etc

# Projects to compile from source
RUN  get-package wg wrk \
  && cd wg-wrk* \
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

COPY --from=ruby:2-alpine /usr/local/lib/ /usr/local/lib/
COPY --from=ruby:2-alpine /usr/local/bin/ /usr/local/bin/
COPY --from=ruby:2-alpine /usr/local/include/ /usr/local/include/

RUN  get-package urbanadventurer WhatWeb \
  && cd urbanadventurer-WhatWeb* \
  && make install \
  && cd .. \
  && rm -rf urbanadventurer-WhatWeb* \
  && rm -rf /root/.bundle

COPY --from=wpscanteam/wpscan /usr/local/bundle/bin/ /usr/local/bundle/bin/
COPY --from=wpscanteam/wpscan /usr/local/bundle /usr/local/bundle

RUN /usr/local/bundle/bin/wpscan --update --verbose

# Go packages
COPY --from=golang:alpine /usr/local/go/ /usr/local/go/

ENV GOPATH=/go
ENV PATH=$PATH:/go/bin:/usr/local/go/bin
RUN  go get github.com/nakabonne/ali \
  && go get github.com/cmpxchg16/gobench \
  && rm -rf /go/pkg /root/.cache

# Packages not requiring any compilation
RUN  get-package sullo nikto \
  && cd sullo-nikto* \
  && mv program /nikto \
  && cd /tmp && rm -rf nikto

RUN  get-package sqlmapproject sqlmap \
  && mv sqlmap* /sqlmap

ENV PATH=$PATH:/nikto:/sqlmap
