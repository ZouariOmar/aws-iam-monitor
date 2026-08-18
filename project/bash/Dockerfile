# =================================
# AWS IAM Monitor - Bash Dockerfile
# =================================

FROM alpine:latest

RUN apk add --no-cache \
  bash \
  make \
  aws-cli \
  jq \
  sed \
  zip \
  openssl \
  python3 \
  curl \
  ca-certificates

WORKDIR /app/bash

COPY . .

RUN chmod +x awsctl \
  lib/* \
  iam/src/* \
  cloud-trail/src/* \
  sns/src/* sns/test/* \
  event-bridge/src/* event-bridge/test/* \
  lambda/src/* lambda/test/*

CMD ["bash"]
