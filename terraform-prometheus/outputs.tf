output "prometheus_url" {
  description = "URL for accessing Prometheus"
  value       = "http://$(minikube ip):$(kubernetes_service.prometheus.spec.0.ports.0.node_port)"
}