resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = "services"
    labels = {
      app = "backend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = "your-backend-image:latest" # Replace with your actual backend image

          env {
            name  = "DB_HOST"
            value = kubernetes_service.postgres.metadata[0].name
          }
          env {
            name  = "DB_USER"
            value = "user"
          }
          env {
            name  = "DB_PASSWORD"
            value = "password"
          }
          env {
            name  = "DB_NAME"
            value = "mydb"
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = "services"
  }

  spec {
    selector = {
      app = kubernetes_deployment.backend.metadata[0].labels.app
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}