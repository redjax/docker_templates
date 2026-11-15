# Grafana - Provision Directory

This directory is mounted in the container with [the `compose.yml` file for Grafana](../../../overlays/grafana.yml). [Read more about Grafana provisioning](https://grafana.com/tutorials/provision-dashboards-and-data-sources/) in the Grafana docs.

## Datasources

The [`datasources/` directory](../../provision/datasources/) is where you define the backends Grafana should be initialized with. You can pre-configure a [Prometheus](./datasources/prometheus-default.yml) or [Loki](./datasources/loki-default.yml) datasource, and it will automatically be "hooked up" in Grafana when it starts.

## Dashboards

`...`
