variable "grafana_version" {
  description = "Version of Grafana to deploy"
  type        = string
  default     = "8.0.6"
}

variable "prometheus_version" {
  description = "Version of Prometheus to deploy"
  type        = string
  default     = "latest"
}