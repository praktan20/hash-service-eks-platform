Hash Service (FastAPI) on EKS

A lightweight FastAPI service that allows you to:

Store strings and retrieve them using their SHA256 hash.

Persist data using PostgreSQL.

Deploy easily on AWS EKS using Terraform and Kustomize.

Containerized with Docker for reproducibility.

Features

Endpoints:

Endpoint	Method	Description
/store	POST	Accepts a string, stores it in PostgreSQL, and returns its SHA256 hash.
/lookup/{hash}	GET	Returns the original string if the SHA256 hash exists in the database.

Persistence: Data is stored externally in PostgreSQL (RDS) for durability.

Headless Service: No web frontend, API-only.

Architecture
User -> ELB -> EKS FastAPI Pods -> PostgreSQL RDS


Terraform: Provision VPC, EKS cluster, security groups, and RDS.

Kustomize: Deploy Kubernetes manifests declaratively.

Docker: Build and run the application locally or in Kubernetes.

Deployment
1. Provision Infrastructure
terraform init
terraform validate
terraform plan
terraform apply


This will create:

VPC with public/private subnets

EKS cluster

Managed node group

RDS PostgreSQL database

2. Deploy Application to EKS

Build Docker image:

docker build -t fastapi-hash .


Push image to your ECR (or another registry) and update k8s/deployment.yaml image tag.

Apply Kustomize manifests:

kubectl apply -k k8s/


Check pods and service:

kubectl get pods -n hash-app
kubectl get svc -n hash-app


Use the EXTERNAL-IP from the LoadBalancer service to access the API.

3. Test API

Store a string:

curl -X POST "http://<EXTERNAL-IP>/store?value=hello"


Lookup a string by hash:

curl "http://<EXTERNAL-IP>/lookup/<SHA256-HASH>"


Swagger UI: http://<EXTERNAL-IP>/docs

Run Locally (Optional)
docker build -t fastapi-hash .
docker run -p 8080:8080 fastapi-hash


Access API: http://localhost:8080/store?value=hello

Lookup: (http://ad0c998b3a26c4677ba20040362efa90-1734251524.us-east-2.elb.amazonaws.com/docs]

Requirements

Terraform >= 1.5

AWS CLI configured with permissions

kubectl >= 1.32

Docker

PostgreSQL (for local testing)

License

MIT License

I can also enhance it further with a diagram of EKS + RDS architecture and step-by-step screenshots to make it visually appealing for GitHub.
