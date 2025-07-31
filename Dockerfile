# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder

# 1. Stage: Go Builder (mit Go 1.21 Alpine)
ARG GOOS=linux
ARG GOARCH=amd64
ARG GOARM=7

WORKDIR /app

# Abhängigkeiten laden (go.mod, go.sum)
COPY go.mod go.sum ./
RUN go mod download

# Quellcode kopieren
COPY . ./

# Programm für Zielarchitektur bauen, GOARM nur wenn gesetzt (für ARM)
RUN CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH GOARM=${GOARM} \
  go build -ldflags="-s -w" -o speedtest_exporter ./cmd/speedtest_exporter

# 2. Stage: Minimalistisches Runtime-Image (distroless)
FROM gcr.io/distroless/static

COPY --from=builder /app/speedtest_exporter /speedtest_exporter

ENTRYPOINT ["/speedtest_exporter"]
