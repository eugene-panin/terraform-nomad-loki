output "job_id" {
  description = "ID of the Loki job in Nomad."
  value       = nomad_job.loki.id
}

output "service_name" {
  description = "Consul service name clients reach Loki by."
  value       = var.job_name
}

output "http_port" {
  description = "Port Loki serves its HTTP API on."
  value       = var.http_port
}

output "data_volume" {
  description = "Name of the dynamic host volume holding the logs."
  value       = nomad_dynamic_host_volume.data.name
}
