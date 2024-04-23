# LocalTelemetry

Local dashboards for telemetry collection.

## To Use

Clone this repository, and then run:

```
docker-compose up
```

Configure your application to send OpenTelemetry data (traces, logs, and metrics) to `localhost:4317` (the standard/default OTLP endpoint).

Then you will have access to the dasboards below:

[Seq (logs + traces)](http://localhost:8080/)

[Jaegar (traces)](http://localhost:16686/)

[Zipkin (traces)](http://localhost:9411/)

[Grafana (metrics)](http://localhost:3000/)

[Aspire (logs + traces + metrics)](http://localhost:18888/)

## Persistence

This project uses Docker volumes for persistence; logs and metrics are persisted, as are Grafana dashboard definitions.

Traces are _not_ persisted.

## Contributing

It would be great to have some good Grafana dashboard definitions out of the box.
