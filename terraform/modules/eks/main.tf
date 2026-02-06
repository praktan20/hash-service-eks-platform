module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa = true
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      name = "default-ng"

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      subnet_ids = var.subnet_ids
    }
  }

  tags = {
    Terraform = "true"
    Env       = "dev"
  }
}
