#!/bin/sh

# Base exporters arrays
TRACES_EXPORTERS="debug,  otlp_grpc/grafana, otlp_grpc/jaeger, zipkin, otlp_http/seq, otlp_grpc/aspire"
METRICS_EXPORTERS="debug, otlp_grpc/grafana, otlp_grpc/aspire"
LOGS_EXPORTERS="debug, otlp_grpc/grafana, otlp_http/seq, otlp_grpc/aspire"

# Programmatically append vendor exporters based on active environment variables
if [ -n "$HONEYCOMB_API_KEY" ]; then
    echo "[OTel Bootstrap] Enabling Honeycomb exporter..."
    TRACES_EXPORTERS="$TRACES_EXPORTERS, otlp_grpc/honeycomb"
    METRICS_EXPORTERS="$METRICS_EXPORTERS, otlp_grpc/honeycomb"
    LOGS_EXPORTERS="$LOGS_EXPORTERS, otlp_grpc/honeycomb"
fi

# Add Azure Monitor only when at least one signal endpoint is configured.
AZURE_EXPORTER_CONFIG=""
if [ -n "${AZURE_TRACES_ENDPOINT:-}" ] || [ -n "${AZURE_LOGS_ENDPOINT:-}" ] || [ -n "${AZURE_METRICS_ENDPOINT:-}" ]; then
    echo "[OTel Bootstrap] Enabling Azure Monitor exporter..."
    AZURE_EXPORTER_CONFIG='  otlp_http/azuremonitor:
    traces_endpoint: "${env:AZURE_TRACES_ENDPOINT}"
    logs_endpoint: "${env:AZURE_LOGS_ENDPOINT}"
    metrics_endpoint: "${env:AZURE_METRICS_ENDPOINT}"
    auth:
      authenticator: azure_auth
'

    if [ -n "${AZURE_TRACES_ENDPOINT:-}" ]; then
        TRACES_EXPORTERS="$TRACES_EXPORTERS, otlp_http/azuremonitor"
    fi
    if [ -n "${AZURE_METRICS_ENDPOINT:-}" ]; then
        METRICS_EXPORTERS="$METRICS_EXPORTERS, otlp_http/azuremonitor"
    fi
    if [ -n "${AZURE_LOGS_ENDPOINT:-}" ]; then
        LOGS_EXPORTERS="$LOGS_EXPORTERS, otlp_http/azuremonitor"
    fi
fi

# Construct a raw YAML string for the pipelines block using the built array
if [ -n "$AZURE_EXPORTER_CONFIG" ]; then
    DYNAMIC_PIPELINE="yaml:
exporters:
$AZURE_EXPORTER_CONFIG
service:
  extensions: [azure_auth]
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [$TRACES_EXPORTERS]
    metrics:
      receivers: [otlp]
      exporters: [$METRICS_EXPORTERS]
    logs:
      receivers: [otlp]
      exporters: [$LOGS_EXPORTERS]
"
else
    DYNAMIC_PIPELINE="yaml:
service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [$TRACES_EXPORTERS]
    metrics:
      receivers: [otlp]
      exporters: [$METRICS_EXPORTERS]
    logs:
      receivers: [otlp]
      exporters: [$LOGS_EXPORTERS]
"
fi

echo "[OTel Bootstrap] Activating pipeline exporters: [$TRACES_EXPORTERS], [$METRICS_EXPORTERS], [$LOGS_EXPORTERS]"

# Execute the collector, appending the dynamic YAML inline string layer
exec otelcol --config=/etc/collector/otel-collector-config.yaml --config="$DYNAMIC_PIPELINE"
