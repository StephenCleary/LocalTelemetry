# Pull the official collector binary
FROM otel/opentelemetry-collector:latest AS binary

# Use Alpine to get shell support
FROM alpine:latest
RUN apk --update add ca-certificates
COPY --from=binary /otelcol /usr/local/bin/otelcol
