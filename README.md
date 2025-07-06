# GKE Infrastructure with Terraform and Helm

## Overview

This repository provisions a complete GKE-based infrastructure using Terraform, deploys a monitoring stack with Helm, and launches a 3-tier sample application. It includes:

* GKE cluster provisioning
* Kubernetes namespaces
* Monitoring stack (Prometheus + Grafana)
* TLS with self-signed certs and Ingress
* 3-tier app (frontend, backend, database)

---

## Directory Structure

```
tf-gke-project/
├── modules/
│   └── gke_cluster/
│       ├── main.tf
│       ├── variables.tf
│       └── output.tf
├── helm-values/
│   ├── grafana-values.yaml
│   └── prometheus-values.yaml
├── k8s/
│   ├── namespaces.tf
│   ├── monitoring_stack.tf
│   ├── services_db.tf
│   ├── services_backend.tf
│   ├── services_frontend.tf
│   └── services_tls.tf
├── certs/
│   ├── tls.crt
│   └── tls.key
├── provider.tf
├── terraform.tfvars
├── production.tf
├── README.md
└── architecture.png
```

---

## Requirements

* Terraform >= 1.3
* Helm
* Google Cloud SDK (gcloud)
* kubectl

---

## Setup Instructions

### 1. Authentication

```bash
export GOOGLE_APPLICATION_CREDENTIALS="<path-to-sa-key>.json"
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud auth application-default login
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan & Apply

```bash
terraform plan
terraform apply -auto-approve
```

### 4. Connect to Cluster

```bash
gcloud container clusters get-credentials <CLUSTER_NAME> --region <REGION> --project <PROJECT_ID>
kubectl get nodes
```

---

## TLS Certificate Creation

```bash
mkdir certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/tls.key -out certs/tls.crt \
  -subj "/CN=frontend.services"
```

Used in `services_tls.tf` to create a Kubernetes TLS secret and expose via Ingress.

---

## Application Structure

* **Frontend**: Exposed via Ingress with TLS and IP restriction
* **Backend**: Internal ClusterIP service
* **Postgres DB**: Stateful with PVC

---

## Monitoring Stack

* Installed via Helm in the `monitoring` namespace
* Prometheus + Grafana
* Grafana exposed with restricted IP access

---

## Optional: Vault/ArgoCD

*Not implemented in this version.*

---

## Time & Assumptions

* \~6 hours total
* Assumes public GKE access and static IPs for ingress
* Known limitations: no auto-scaling, no HA database

---

## Architecture

See `architecture.png` for a visual representation of the repo and deployment layout.
