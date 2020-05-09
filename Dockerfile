FROM ruby:2.6.3-alpine

RUN apk update && apk add --no-cache \
    make gcc g++ libc-dev \
    tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone && \
    apk del tzdata
    
WORKDIR /app
