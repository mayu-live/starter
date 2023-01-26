# syntax = docker/dockerfile:experimental
ARG RUBY_VERSION=3.2.0
ARG VARIANT=jemalloc-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT} as base

ARG BUNDLER_VERSION=2.3.11

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH ${BUNDLE_PATH}
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

SHELL ["/bin/bash", "-c"]

RUN mkdir /app
WORKDIR /app
RUN mkdir -p tmp/pids

################
## build base ##
################

FROM base as build-base

WORKDIR /build

ENV DEV_PACKAGES git build-essential wget vim curl gzip xz-utils npm webp imagemagick brotli

RUN \
    --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y ${DEV_PACKAGES} && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN gem install -N bundler -v ${BUNDLER_VERSION}

####################
## build mayu gem ##
####################

WORKDIR /build

FROM build-base as build-gem-1

COPY Gemfile* ./
RUN bundle install

######################
## build js runtime ##
######################

FROM node:19.0.0-alpine3.15 as build-js

RUN apk add --no-cache brotli

COPY --from=build-gem-1 /build/vendor/bundle/ruby/3.2.0/bundler/gems/framework-*/lib/mayu/client /build

WORKDIR /build

RUN \
    npm install && \
    npm run build:production && \
    find . | grep -v node_modules && \
    brotli $(find dist/ -name "*.js") && \
    brotli $(find dist/ -name "*.map") && \
    rm -r node_modules

####################
## build mayu gem ##
####################

FROM build-gem-1 as build-gem-2

RUN bundle package

###############
## build app ##
################

FROM build-base as build-app

WORKDIR /app

COPY Gemfile* ./
COPY --from=build-gem-2 /build/vendor/cache vendor/cache
RUN \
    sed -i 's/, path: "\.\."//' Gemfile && \
    ls -l vendor/cache && \
    bundle install && \
    bundle binstubs mayu-live && \
    rm -rf vendor/bundle/ruby/*/cache && \
    rm -rf vendor/cache

COPY --from=build-js /build/dist /app/js-dist
RUN mv js-dist "$(ls -d1 ./vendor/bundle/ruby/3.2.0/bundler/gems/framework-*/lib/mayu/client | head -n1)"/dist

COPY mayu.toml .
COPY app app

ENV MAYU_SECRET_KEY "nothing secret here, we just need to set something"
RUN bin/mayu build && ls -l app.mayu-bundle

#######################
## build final image ##
#######################

FROM base

COPY fly /fly
COPY --from=build-app /app /app

ENV PORT 3000

WORKDIR /app

CMD ["bin/mayu", "serve", "--disable-sorbet"]
