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
