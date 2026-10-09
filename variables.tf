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
  description = "CPU (MHz) and memory (MB) for the Loki task."
  type = object({
    cpu    = optional(number, 500)
    memory = optional(number, 1024)
  })
  default = {}
}
