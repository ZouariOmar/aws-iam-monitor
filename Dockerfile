# =========================
# AWS IAM Monitor Dockerfile
#
# Bash implementation only (project/bash/). The Terraform
# implementation has no Docker image — run it directly on the host
# (see project/terraform/README.md).
# =========================

FROM alpine:latest

# Install required tools for the Bash implementation
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

WORKDIR /app/project/bash

# Copy only the Bash implementation
COPY project/bash/ .

# Ensure CLI executable permissions
RUN chmod +x awsctl \
  lib/* \
  iam/src/* \
  cloud-trail/src/* \
  sns/src/* sns/test/* \
  event-bridge/src/* event-bridge/test/* \
  lambda/src/* lambda/test/*

# Default command
CMD ["bash"]
