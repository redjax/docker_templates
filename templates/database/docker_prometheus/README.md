# Prometheus

[Prometheus](https://github.com/prometheus/prometheus) is a time series database & monitoring system with a "pull" architecture. Using a [`node_exporter`](./node_exporter/) container, Prometheus can connect to 1 or more remote machines to "pull" metrics like CPU/RAM usage, hard drive space, etc.

## Example Queries

> [!NOTE]
> You can filter logs using `{curly braces}` and a filter name/value. For example, to show only metrics for a single host with IP `192.168.1.16` running `node_exporter` on port `9100`, you could use:
>
> `{instance="192.168.1.16:9100"}`
>
> This is an example query that shows available memory as a % of the total for just `192.168.1.16`:
> 
> ```promql
> (1 - (node_memory_MemAvailable_bytes{instance="192.168.1.16:9100"} / node_memory_MemTotal_bytes{instance="192.168.1.16:9100"})) * 100
> ```

Show non-idle CPU % per core, averaged over 5 minutes:

```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

Show available memory as % of total:

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

Show filesystem utilization; you can set a different `mountpoint="/path/to/drive/mount"` to see stats for other mount points besides `/`:

```promql
## Note: You can view this stat for other mountpoints, too, if those mounts are on different disks.
#  For example, {mountpoint="/mnt/another_drive"}
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100
```

Show total disk throughput per device; filter `{device=~"sd[a-b]"}` for specific drives.

```promql
rate(node_disk_read_bytes_total[5m]) + rate(node_disk_written_bytes_total[5m])

## Or, filtering specific drives
rate(node_disk_read_bytes_total{device=~"sd[a-b]"}[5m]) + rate(node_disk_written_bytes_total{device=~"sd[a-b]"}[5m])
```

Show total bandwidth per interface; add `{device!~"lo"}` to exclude loopback, or `{device=~"eno1|eth.*|docker[0-9]*"}` to filter by specific interface(s), using 1 or more of the patterns listed to narrow by interface:

```promql
rate(node_network_receive_bytes_total{device=~"eno1|eth.*|docker[0-9]*"}[5m]) + rate(node_network_transmit_bytes_total{device=~"eno1|eth.*|docker[0-9]*"}[5m])
```

List all available metrics:

```promql
{__name__=~"node_.*"}
```

## Links

- [Prometheus home](https://prometheus.io)
- [Prometheus Github](github.com/prometheus/prometheus)
- [Prometheus Docs](https://prometheus.io/docs/introduction/overview/)
  - [Prometheus docs: querying basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
    - [Prometheus PromQL cheat sheet](https://promlabs.com/promql-cheat-sheet/)
