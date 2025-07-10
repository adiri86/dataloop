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

 1. Create a Service Account and JSON Key
	Step-by-Step via Console
	Go to: https://console.cloud.google.com/iam-admin/serviceaccounts
	Click "Create Service Account"
	
	Set:
		Name: terraform
		ID: terraform
	
	Click Create and Continue.

1a.Grant these roles:
	
Grant these roles:

		✅ Kubernetes Engine Admin (roles/container.admin)
		
		✅ Compute Admin (roles/compute.admin)
		
		✅ Service Account User (roles/iam.serviceAccountUser)
		
		✅ (optional) Storage Admin (roles/storage.admin) if needed
	
	Click Done

1b. 🔑 Download JSON Key
	Find the new SA in the list.

	Click ⋮ → Manage Keys

	Click "Add Key" → JSON

	Save the .json file securely. This is the key you use in provider.tf.




2. Enable Required APIs
Go to: https://console.cloud.google.com/marketplace/product/google/container.googleapis.com

	Click Enable for the following:

	Service	Purpose
	Kubernetes Engine API	For creating GKE clusters
	Compute Engine API	Needed for creating LBs, disks
	IAM Service Account Credentials API	Needed for SA usage
	Cloud Resource Manager API (optional)	If managing orgs/projects

	Or run this in gcloud:

	gcloud services enable container.googleapis.com compute.googleapis.com iamcredentials.googleapis.com





3. Assign IAM Roles to the Service Account:
	🅰️ Via Console (IAM → Permissions)

	Go to https://console.cloud.google.com/iam-admin/iam

	Click "Grant access"

	Select the service account email

	Assign:
			✅ Kubernetes Engine Admin
			✅ Compute Admin			
			✅ Service Account User
			✅ (Optional) Storage Admin

	🅱️ Or via gcloud:

			PROJECT_ID="your-project-id"
			SA_EMAIL="terraform@${PROJECT_ID}.iam.gserviceaccount.com"
		
			gcloud projects add-iam-policy-binding "$PROJECT_ID" \
			  --member="serviceAccount:${SA_EMAIL}" \
			  --role="roles/container.admin"
		
			gcloud projects add-iam-policy-binding "$PROJECT_ID" \
			  --member="serviceAccount:${SA_EMAIL}" \
			  --role="roles/compute.admin"
		
			gcloud projects add-iam-policy-binding "$PROJECT_ID" \
			  --member="serviceAccount:${SA_EMAIL}" \
			  --role="roles/iam.serviceAccountUser"
		  
  

  
4. Use the Service Account in Terraform
In provider.tf:

provider "google" {
  credentials = file("path/to/terraform-sa.json")
  project     = "your-project-id"
  region      = "us-east4"
}


5.
	gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
	gcloud auth application-default login



6. Initialize Terraform
terraform init


7. Plan & Apply
terraform plan
terraform apply -auto-approve



8. Connect to Cluster
gcloud container clusters get-credentials <CLUSTER_NAME> --region <REGION> --project <PROJECT_ID>
kubectl get nodes

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
