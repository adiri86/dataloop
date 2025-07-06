esource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = "services"
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:14"

          env {
            name  = "POSTGRES_DB"
            value = "mydb"
          }
          env {
            name  = "POSTGRES_USER"
            value = "user"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "db-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "db-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.db_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = "services"
  }

  spec {
    selector = {
      app = kubernetes_deployment.postgres.metadata[0].labels.app
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}