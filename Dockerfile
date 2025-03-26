#syntax=docker/dockerfile:1.7-labs
FROM golang:1.23.6 AS builder
WORKDIR /app

COPY go.* ./
RUN go mod download
COPY . ./
RUN go build -C .start/ -o workflow
RUN go build -C .worker/ -o worker

FROM debian:bookworm-slim
# the cache is mounted only
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt/,type=cache,sharing=locked \
    set -x && rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && apt-get install -y \
    ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /start/workflow /app/workflow
COPY --from=builder /worker/worker /app/worker
CMD ["/app/workflow && /app/worker"]
