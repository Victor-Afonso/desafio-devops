provider "kubernetes" {
  config_context_cluster    = "minikube"
  config_path               = "~/.kube/config"  # Update with your actual kubeconfig path
}
