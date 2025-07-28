# FROM gcr.io/distroless/static
# ENTRYPOINT ["/speedtest_exporter"]
# COPY speedtest_exporter /

# 1. Stage: Go Builder (mit Go 1.21 Alpine)
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Abhängigkeiten laden (go.mod, go.sum)
COPY go.mod go.sum ./
RUN go mod download

# Quellcode kopieren
COPY . .

# Programm für Linux bauen (statisch, ohne CGO)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o speedtest_exporter ./cmd/speedtest_exporter

# 2. Stage: Minimalistisches Runtime-Image (distroless)
FROM gcr.io/distroless/static

# Binary aus Builder-Stage kopieren
COPY --from=builder /app/speedtest_exporter /speedtest_exporter

# Binary als EntryPoint setzen
ENTRYPOINT ["/speedtest_exporter"]
