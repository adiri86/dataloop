resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "services"
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = "your-frontend-image:latest" # Replace with your actual frontend image

          env {
            name  = "API_URL"
            value = "http://${kubernetes_service.backend.metadata[0].name}:8080"
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "services"
  }

  spec {
    selector = {
      app = kubernetes_deployment.frontend.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"

    load_balancer_source_ranges = [
      "YOUR_ALLOWED_IP/32"  # Replace with your allowed IP or CIDR block
    ]
  }
}
