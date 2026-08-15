# =========================
# AWS IAM Monitor Dockerfile
# =========================

FROM alpine:latest

# Install required tools
RUN apk add --no-cache \
  bash \
  make \
  uv \
  aws-cli \
  jq \
  sed \
  zip \
  openssl \
  python3 \
  curl \
  ca-certificates

WORKDIR /app

# Copy project
COPY . .

# Default command
CMD ["bash"]
