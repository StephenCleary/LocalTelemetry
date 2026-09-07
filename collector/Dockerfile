# Pull the official collector binary
FROM otel/opentelemetry-collector-contrib:latest AS binary

# Use Alpine to get shell support
FROM alpine:latest
RUN apk --update add ca-certificates
COPY --from=binary /otelcol-contrib /usr/local/bin/otelcol
