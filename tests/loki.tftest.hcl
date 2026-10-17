mock_provider "consul" {}
mock_provider "nomad" {}

run "it_exposes_a_consul_service_with_the_default_config" {
  command = apply

  assert {
    condition     = output.service_name == "loki" && output.http_port == 3100
    error_message = "Loki is not exposed as the expected Consul service and port."
  }

  assert {
    condition     = strcontains(nomad_job.loki.jobspec, "retention_period: 168h")
    error_message = "The default config with its retention was not written."
  }

  assert {
    condition     = !strcontains(nomad_job.loki.jobspec, "host_network = \"public\"")
    error_message = "Logs must never bind the public host network."
  }
}

run "memory_is_reserved_by_use_and_may_grow" {
  command = apply

  assert {
    condition     = strcontains(nomad_job.loki.jobspec, "memory     = 256") && strcontains(nomad_job.loki.jobspec, "memory_max = 1024")
    error_message = "The task must reserve its usual memory and be allowed to grow to memory_max."
  }
}

run "it_joins_the_mesh" {
  command = apply

  variables {
    mesh = { enabled = true, allow = ["grafana"] }
  }

  assert {
    condition = (
      strcontains(nomad_job.loki.jobspec, "transparent_proxy")
      && strcontains(nomad_job.loki.jobspec, "exclude_inbound_ports = [\"3100\",\"9102\"]")
      && strcontains(nomad_job.loki.jobspec, "name     = \"loki-envoy\"")
      && strcontains(nomad_job.loki.jobspec, "uid                   = \"1337\"")
    )
    error_message = "In the mesh Loki must sit behind an Envoy sidecar, keep its HTTP port open for Alloy, and expose Envoy's metrics."
  }

  assert {
    condition = (
      jsondecode(consul_config_entry.intentions[0].config_json).Sources == [{ Name = "grafana", Action = "allow", Precedence = 9, Type = "consul" }]
      && jsondecode(consul_config_entry.defaults[0].config_json).Protocol == "http"
    )
    error_message = "Only the allowed services may connect, and the protocol is http."
  }
}

run "out_of_the_mesh_by_default" {
  command = apply

  assert {
    condition     = !strcontains(nomad_job.loki.jobspec, "connect {") && length(consul_config_entry.intentions) == 0
    error_message = "Without mesh.enabled there is no sidecar and no intentions."
  }
}

run "the_service_carries_the_tags_and_meta_given" {
  command = apply

  variables {
    service_tags = ["damstack.provides=logs@1"]
    service_meta = { kind = "example" }
  }

  assert {
    condition     = strcontains(nomad_job.loki.jobspec, "tags     = [\"damstack.provides=logs@1\"]") && strcontains(nomad_job.loki.jobspec, "meta {") && strcontains(nomad_job.loki.jobspec, "kind = \"example\"")
    error_message = "The service must carry the tags and meta given."
  }
}

run "the_service_has_no_tags_or_meta_by_default" {
  command = apply

  assert {
    condition     = !strcontains(nomad_job.loki.jobspec, "damstack.provides") && length(regexall("\n      meta {", nomad_job.loki.jobspec)) == 0
    error_message = "Without service_tags and service_meta the service must be as before."
  }
}
