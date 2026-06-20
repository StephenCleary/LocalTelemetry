#!/bin/sh

# Base exporters arrays
TRACES_EXPORTERS="debug, otlp/grafana, otlp/jaeger, zipkin, otlphttp/seq, otlp/aspire"
METRICS_EXPORTERS="debug, otlp/grafana, otlp/aspire"
LOGS_EXPORTERS="debug, otlp/grafana, otlphttp/seq, otlp/aspire"

# Programmatically append vendor exporters based on active environment variables
if [ -n "$HONEYCOMB_API_KEY" ]; then
    echo "[OTel Bootstrap] Enabling Honeycomb exporter..."
    TRACES_EXPORTERS="$TRACES_EXPORTERS, otlp/honeycomb"
    METRICS_EXPORTERS="$METRICS_EXPORTERS, otlp/honeycomb"
    LOGS_EXPORTERS="$LOGS_EXPORTERS, otlp/honeycomb"
fi

# Construct a raw YAML string for the pipelines block using the built array
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

echo "[OTel Bootstrap] Activating pipeline exporters: [$TRACES_EXPORTERS], [$METRICS_EXPORTERS], [$LOGS_EXPORTERS]"

# Execute the collector, appending the dynamic YAML inline string layer
exec otelcol --config=/etc/collector/otel-collector-config.yaml --config="$DYNAMIC_PIPELINE"
