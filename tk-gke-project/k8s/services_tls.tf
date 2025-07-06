resource "kubernetes_secret" "frontend_tls" {
  metadata {
    name      = "frontend-tls"
    namespace = "services"
  }

  data = {
    "tls.crt" = filebase64("${path.module}/../certs/tls.crt")
    "tls.key" = filebase64("${path.module}/../certs/tls.key")
  }                                                                                                                                                                                 

  type = "kubernetes.io/tls"
}     
Create an Ingress resource to expose frontend with TLS:

hcl
Copy
Edit
resource "kubernetes_ingress" "frontend" {
  metadata {
    name      = "frontend-ingress"
    namespace = "services"
    annotations = {
      "kubernetes.io/ingress.class" : "gce"  # or your ingress controller
    }
  }

  spec {                                                                                
    tls {                          
      secret_name = kubernetes_secret.frontend_tls.metadata[0].name
    }

    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.frontend.metadata[0].name
            service_port = 80
          }
        }
      }
    }
  }
}