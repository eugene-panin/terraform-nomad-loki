# Changelog

## v0.1.0

- Loki as a single-process log store on a Nomad platform: one job, logs in a
  dynamic host volume the platform's backup copies by name (`meta.backup = "stop"`).
- A Consul service clients push to and query, health-checked on `/ready`, bound
  to the internal host network only.
- A built-in single-process filesystem config with a configurable retention; a
  full `config` overrides it.

## v0.1.1

- The data volume is owned by uid 10001, the Loki image's user, so Loki can write it.

## v0.1.2

- The task reserves 256 MB, sized to its use, and may grow to 1024 MB:
  `resources.memory_max` (Nomad memory oversubscription, which the platform
  turns on). It reserved more than it used before.

## v0.1.3

- `mesh`: Loki can join the Consul service mesh — an Envoy sidecar with the
  transparent proxy, so mesh services (the dashboards) reach it as
  `<job_name>.virtual.consul` over mTLS as `mesh.allow` lets them
  (service-intentions). The HTTP port stays open for the platform's Alloy, which
  pushes from the host. Envoy's metrics are a `<job_name>-envoy` service tagged
  for Alloy.
