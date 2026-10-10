variable "namespace" {
  description = "Nomad namespace the job runs in."
  type        = string
  default     = "default"
}

variable "job_name" {
  description = "Name of the Nomad job and the Consul service clients push to and read from."
  type        = string
  default     = "loki"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}$", var.job_name))
    error_message = "job_name must be lowercase letters, digits and -, starting with a letter."
  }
}

variable "datacenters" {
  description = "Nomad datacenters the job may run in."
  type        = list(string)
  default     = ["*"]
}

variable "image" {
  description = "Loki container image, pinned by a fixed tag or a digest."
  type        = string
  default     = "grafana/loki:3.7.8"
}

variable "http_port" {
  description = "Port Loki serves its HTTP API (push and query) on, on the internal host network."
  type        = number
  default     = 3100
}

variable "grpc_port" {
  description = "Port Loki serves gRPC on."
  type        = number
  default     = 9096
}

variable "retention_period" {
  description = "How long logs are kept, as a Go duration (the default config honours it)."
  type        = string
  default     = "168h"
}

variable "config" {
  description = "Loki configuration (loki.yml), verbatim. Null uses the built-in single-process filesystem config with retention_period."
  type        = string
  default     = null
}

variable "internal_host_network" {
  description = "Nomad host network Loki binds to. Never the public network: logs are reachable only inside the platform."
  type        = string
  default     = "default"
}

variable "resources" {
  description = "CPU (MHz) and memory (MB) for the Loki task: memory is what it reserves (sized to its use), memory_max how far it may grow (Nomad memory oversubscription)."
  type = object({
    cpu        = optional(number, 500)
    memory     = optional(number, 256)
    memory_max = optional(number, 1024)
  })
  default = {}
  validation {
    condition     = var.resources.memory_max >= var.resources.memory
    error_message = "resources.memory_max must be at least resources.memory."
  }
}

variable "mesh" {
  description = <<-EOT
    The Consul service mesh. enabled puts Loki behind an Envoy sidecar (transparent proxy):
    mesh services reach it as <job_name>.virtual.consul over mTLS, and only those in allow
    may (Consul intentions). The HTTP port stays reachable outside the mesh, for the
    platform's Alloy that pushes from the host; keep_open_ports are kept open as well.
    protocol is what Consul's L7 features see: http.
  EOT
  type = object({
    enabled         = optional(bool, false)
    allow           = optional(list(string), [])
    keep_open_ports = optional(list(number), [])
    protocol        = optional(string, "http")
  })
  default = {}
  validation {
    condition     = contains(["tcp", "http", "http2", "grpc"], var.mesh.protocol)
    error_message = "mesh.protocol must be tcp, http, http2 or grpc."
  }
}
