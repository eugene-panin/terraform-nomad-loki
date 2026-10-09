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
