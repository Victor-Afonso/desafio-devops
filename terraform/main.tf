# Configure Kubernetes provider and connect to the Kubernetes API server
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

# Create a Quarkus API Deployment
resource "kubernetes_deployment" "quarkus_api" {
  metadata {
    name = "quarkus-api"
    labels = {
      app = "quarkus-api"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "quarkus-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "quarkus-api"
        }
      }

      spec {
        container {
          image = "quarkus/first-project-jvm:1.0.1"
          name  = "quarkus-api"
          image_pull_policy = "Never"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Create a Quarkus API Service
resource "kubernetes_service" "quarkus_api" {
  metadata {
    name = "quarkus-api"
  }

  spec {
    selector = {
      app = kubernetes_deployment.quarkus_api.metadata.0.labels.app
    }

    port {
      port        = 8080
      target_port = 8080
    }
    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_deployment.quarkus_api
  ]
}

# Create a Redis Deployment
resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          image = "redis:latest"
          name  = "redis"
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

# Create a Redis Service
resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
  }

  spec {
    selector = {
      app = kubernetes_deployment.redis.metadata.0.labels.app
    }

    port {
      port        = 6379
      target_port = 6379
    }

    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_deployment.redis
  ]
}