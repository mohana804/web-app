# ---- Build stage ----
FROM golang:1.22 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# ---- Runtime stage ----
FROM debian:bullseye-slim
WORKDIR /app
COPY --from=builder /app/main /app/main
EXPOSE 8080
USER 65532:65532
ENTRYPOINT ["/app/main"]
