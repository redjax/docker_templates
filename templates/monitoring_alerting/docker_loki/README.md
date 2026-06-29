# Loki

[Loki](https://github.com/grafana/loki) is a log aggregation service, "like Prometheus, but for logs." It is an alternative to the Elastic stack, lighter on resources and simpler to install/configure.

A [Grafana container](./overlays/grafana.yml) is also included for exploring Loki. To use, run `docker compose -f compose.yml -f overlays/grafana.yml up -d`. Open the Grafana URL at `http://<host-or-ip>:3000` and add Loki as a datasource using the URL `http://loki:3100`.
