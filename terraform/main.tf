############################################
# Provider (Single AZ / Minimum Cost)
############################################
provider "aws" {
  region = "us-east-1"
}

############################################
# VPC - Single AZ, No NAT (Lowest Cost)
############################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "hash-service-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]

  # Cost optimization
  enable_nat_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "dev"
    CostModel   = "minimum"
    Terraform   = "true"
  }
}

############################################
# EKS Cluster - Single AZ / Public Nodes
############################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "hash-service"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  enable_irsa = true

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      name           = "default-ng"

      # Cheapest instance type that works reliably with EKS
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      capacity_type = "ON_DEMAND"

      tags = {
        NodeGroup = "default"
        CostModel = "minimum"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

############################################
# Security Group for RDS
############################################
resource "aws_security_group" "rds" {
  name        = "hash-service-rds-sg"
  description = "Allow Postgres from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# RDS Subnet Group (Single AZ)
############################################
resource "aws_db_subnet_group" "postgres" {
  name       = "hash-service-db-subnet-group"
  subnet_ids = module.vpc.public_subnets
}

############################################
# RDS PostgreSQL - Single AZ / Lowest Cost
############################################
resource "aws_db_instance" "postgres" {
  identifier = "hash-service-postgres"

  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"  # cheapest RDS class

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "hashdb"
  username = "hashuser"
  password = "changeme123"  # demo only

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name

  publicly_accessible = false
  multi_az            = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "hash-service-postgres"
    CostModel  = "minimum"
    Environment = "dev"
  }
}

############################################
# IAM: EKS Admin Role (for User Authentication)
############################################
resource "aws_iam_role" "eks_admin" {
  name = "hash-service-eks-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS managed admin policy (simple + interview friendly)
resource "aws_iam_role_policy_attachment" "eks_admin_attach" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

############################################
# EKS Access Entry (IAM → Kubernetes RBAC)
############################################
resource "aws_eks_access_entry" "admin" {
  cluster_name = module.eks.cluster_name
  principal_arn = aws_iam_role.eks_admin.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name = module.eks.cluster_name
  principal_arn = aws_iam_role.eks_admin.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

############################################
# Data Sources
############################################
data "aws_caller_identity" "current" {}

############################################
# Outputs
############################################
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}
