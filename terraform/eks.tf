module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "hash-service"
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 2
    }
  }
}
