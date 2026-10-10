# terraform-nomad-loki

Loki on a Nomad platform that has Consul — such as
[hashi](https://github.com/eugene-panin/damstack-hashi). The
[damstack-loki](https://github.com/eugene-panin/damstack-loki) stack wires it.

A single-process log store on local disk: one Nomad job, the logs in a host
volume, exposed as a Consul service clients push to and query. No auth — it is
reachable only inside the platform. A collector (the platform's Alloy) pushes
logs to it; Grafana queries it.

## Inputs

| Name | Default | What |
| --- | --- | --- |
| `job_name` | `loki` | Nomad job and Consul service name |
| `namespace` | `default` | Nomad namespace |
| `datacenters` | `["*"]` | Nomad datacenters |
| `image` | `grafana/loki:3.7.8` | image, pinned |
| `http_port` | `3100` | HTTP API (push and query) |
| `grpc_port` | `9096` | gRPC |
| `retention_period` | `168h` | how long logs are kept (default config) |
| `config` | built-in | full `loki.yml` to override the single-process filesystem default |
| `internal_host_network` | `default` | host network it binds to |
| `resources` | `{500, 1024}` | `{cpu, memory}` |

## Outputs

`job_id`, `service_name`, `http_port`, `data_volume`.

## Development

```sh
make lint
make module-tests
```

## Service mesh

With `mesh.enabled`, the job gets an Envoy sidecar (transparent proxy) and
Consul config entries: `service-defaults` (`mesh.protocol`, http) and
`service-intentions` allowing `mesh.allow`. Mesh clients query
`http://<job_name>.virtual.consul:3100`. The HTTP port stays open: the
platform's Alloy pushes logs to it from the host, outside the mesh.
