# Hash Service on EKS

## Features
- Store strings and retrieve via SHA256 hash
- Persistent storage using PostgreSQL
- Containerized with Docker
- Deployed to EKS using Helm
- Provisioned using Terraform

## Deploy
```bash

terraform init
terraform validate
terraform plan
terraform apply
## Run Locally
```bash
docker build -t fastapi-hash .
docker run -e DATABASE_URL=postgresql://... -p 8000:8000 fastapi-hash
kubectl apply -f k8s/
