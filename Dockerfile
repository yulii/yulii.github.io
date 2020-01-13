FROM ruby:2.6.3-alpine

RUN apk update && apk add --no-cache \
    make gcc g++ libc-dev

WORKDIR /app
