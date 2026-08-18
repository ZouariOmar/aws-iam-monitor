# ======================================
# AWS IAM Monitor - Terraform Dockerfile
# ======================================

FROM hashicorp/terraform:latest

RUN apk add --no-cache \
  bash \
  make \
  aws-cli \
  curl \
  ca-certificates

WORKDIR /app/terraform

COPY . .

ENTRYPOINT []
CMD ["bash"]
