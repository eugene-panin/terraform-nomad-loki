locals {
  volume_name = "${var.job_name}-data"

  default_config = <<-EOT
    auth_enabled: false
    server:
      http_listen_port: ${var.http_port}
      grpc_listen_port: ${var.grpc_port}
    common:
      path_prefix: /loki
      storage:
        filesystem:
          chunks_directory: /loki/chunks
          rules_directory: /loki/rules
      replication_factor: 1
      ring:
        kvstore:
          store: inmemory
    schema_config:
      configs:
        - from: 2026-01-01
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: index_
            period: 24h
    limits_config:
      retention_period: ${var.retention_period}
    compactor:
      working_directory: /loki/compactor
      retention_enabled: true
      delete_request_store: filesystem
  EOT

  config = coalesce(var.config, local.default_config)
}

resource "nomad_dynamic_host_volume" "data" {
  name      = local.volume_name
  namespace = var.namespace
  plugin_id = "mkdir"

  parameters = {
    mode = "0700"
    uid  = "10001"
    gid  = "10001"
  }

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_job" "loki" {
  jobspec = templatefile("${path.module}/templates/loki.nomad.hcl.tftpl", {
    job_name         = var.job_name
    namespace        = var.namespace
    datacenters      = var.datacenters
    volume_name      = nomad_dynamic_host_volume.data.name
    internal_network = var.internal_host_network
    image            = var.image
    config           = local.config
    http_port        = var.http_port
    grpc_port        = var.grpc_port
    resources        = var.resources
  })

  purge_on_destroy = true
}
