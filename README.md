---

# 🛡️ Hash Service (FastAPI) on EKS

A resilient FastAPI microservice built for cloud-native environments, focused on **secure data hashing**, **persistent storage**, and **easy deployment** to **AWS EKS** using **Terraform** and **Kustomize**. 🚀

---

## ✨ Features

* 🔹 **Endpoints:** `/store`, `/lookup/{hash}`
* 🔹 **Persistence:** PostgreSQL RDS for durable storage
* 🔹 **Containerized:** Docker for portability
* 🔹 **IaC & GitOps:** Terraform for AWS infra, Kustomize for K8s manifests

---

## 📊 Architecture

```
User ➡️ AWS ELB ➡️ EKS FastAPI Pods ➡️ PostgreSQL RDS
```

---

## ⚙️ Deployment Guide

### **Requirements**

* ✅ Terraform >= 1.5
* ✅ AWS CLI configured
* ✅ kubectl >= 1.32
* ✅ Docker
* ✅ Postgres client (psql)

---

### **Step 1: Provision Infrastructure (Terraform)**

```bash
cd terraform/  # Navigate to Terraform directory
terraform init
terraform validate
terraform plan
terraform apply
```

> ⚠️ Creates VPC, EKS cluster, and RDS PostgreSQL. Use with caution.

---

### **Step 2: Docker Build & Push**

1. **Build Docker Image**

```bash
docker build -t <your-registry>/fastapi-hash .
```

2. **Push to ECR**

```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<region>.amazonaws.com
docker tag fastapi-hash:latest <your-account-id>.dkr.ecr.<region>.amazonaws.com/fastapi-hash:latest
docker push <your-account-id>.dkr.ecr.<region>.amazonaws.com/fastapi-hash:latest
```

---

### **Step 3: Deploy to Kubernetes (EKS)**

```bash
kubectl apply -k k8s/
kubectl get pods -n hash-app
kubectl get svc -n hash-app
```

> Note the **EXTERNAL-IP** of the service for accessing the API.

---

### **Step 4: Verify RDS Table**

Connect to PostgreSQL:

```bash
psql -h <rds-endpoint> -U hashuser -d hashdb
```

Check table:

```sql
\dt
SELECT * FROM strings;
```

> Table `strings` should exist and store SHA256 hash mappings.

---

### **Step 5: Test the API**

| Action          | Command                                                 | Response             |
| --------------- | ------------------------------------------------------- | -------------------- |
| Store a string  | `curl -X POST "http://<EXTERNAL-IP>/store?value=hello"` | `{"hash":"..."}`     |
| Lookup a string | `curl "http://<EXTERNAL-IP>/lookup/<SHA256-HASH>"`      | `{"value":"hello"}`  |
| Swagger UI      | Open `http://<EXTERNAL-IP>/docs`                        | Interactive API docs |

---

### **Step 6: Run Locally**

Requires **local PostgreSQL DB** and `DATABASE_URL` in environment:

```bash
export DATABASE_URL="postgresql://hashuser:changeme123@localhost:5432/hashdb"
docker build -t fastapi-hash .
docker run -p 8080:8080 -e DATABASE_URL=$DATABASE_URL fastapi-hash
```

Access API: `http://localhost:8080/docs`

---

## 🧰 Useful Commands

* **Check Pods**

```bash
kubectl get pods -n hash-app -o wide
```

* **Check Services**

```bash
kubectl get svc -n hash-app
```

* **Describe Pod**

```bash
kubectl describe pod <pod-name> -n hash-app
```

* **Logs**

```bash
kubectl logs deploy/hash-app -n hash-app
```

* **Execute inside Pod**

```bash
kubectl exec -it <pod-name> -n hash-app -- /bin/sh
```

---

## ⚖️ License

MIT License

---

Do you want me to add that diagram?
