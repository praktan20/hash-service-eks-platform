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
helm install hash-service helm/hash-service
