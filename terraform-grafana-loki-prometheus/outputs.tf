output "grafana_url" {
  description = "URL for accessing Grafana"
  value       = "http://$(minikube ip):$(kubernetes_service.grafana.spec.0.ports.0.node_port)"
}

output "prometheus_url" {
  description = "URL for accessing Prometheus"
  value       = "http://$(minikube ip):$(kubernetes_service.prometheus.spec.0.ports.0.node_port)"
}