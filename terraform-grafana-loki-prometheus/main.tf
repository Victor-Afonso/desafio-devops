resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.grafana.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:${var.grafana_version}"

          env {
            name  = "GF_INSTALL_PLUGINS"
            value = "grafana-piechart-panel,grafana-worldmap-panel"
          }

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.prometheus.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:${var.prometheus_version}"

          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus",
            "--web.enable-admin-api",
          ]

          volume_mount {
            name      = "config"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name      = "data"
            mount_path = "/prometheus"
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map.prometheus.metadata.0.name
          }
        }

        volume {
          name = "data"
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.grafana.metadata.0.name
  }

  spec {
    selector = {
      app = "grafana"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 3000
      node_port   = 30080
    }
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.prometheus.metadata.0.name
  }

  spec {
    selector = {
      app = "prometheus"
    }

    type = "NodePort"

    port {
      port        = 9090
      target_port = 9090
      node_port   = 30090
    }
  }
}

resource "kubernetes_config_map" "prometheus" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.prometheus.metadata.0.name
  }

  data = {
    "prometheus.yml" = <<-EOT
      global:
        scrape_interval: 15s
        evaluation_interval: 15s

      scrape_configs:
        - job_name: 'quarkus-api'
          metrics_path: '/q/metrics'
          static_configs:
            - targets: ['quarkus-api.default.svc.cluster.local:8080']
    EOT
  }
}