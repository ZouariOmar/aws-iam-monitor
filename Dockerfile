# =========================
# Generic Dockerfile
# =========================

FROM alpine:3.20

# Install basic runtime tools
RUN apk add --no-cache bash curl

WORKDIR /app

# Copy project
COPY . .

# Optional build step (override in real projects)
# RUN make build

# Default command (override in docker-compose or CLI)
CMD ["bash"]
