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
