provider "google" {
  credentials = file("<path/to/your/google-credentials.json>")
  project     = "<gcp-project-id>"
  region      = "us-east4"
}
/*
 a Kubernetes provider block so Terraform knows how to talk to the cluster and manage Kubernetes resources.
 The provider needs information like API endpoint and credentials, which come from your GKE module outputs. 
 The depends_on forces Terraform to create the cluster before trying to manage Kubernetes resources (like namespaces).
*/
provider "kubernetes" {
  host                   = module.gke_cluster.cluster_endpoint

  client_certificate     = base64decode(module.gke_cluster.client_certificate)
  client_key             = base64decode(module.gke_cluster.client_key)
  cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)

  depends_on = [module.gke_cluster]
}

provider "helm" {
  kubernetes {
    host                   = module.gke_cluster.cluster_endpoint
    client_certificate     = base64decode(module.gke_cluster.client_certificate)
    client_key             = base64decode(module.gke_cluster.client_key)
    cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)
  }
}
