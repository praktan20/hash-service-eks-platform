provider "aws" {
  region = "us-east-1"
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "hash-service"
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t2,micro"]
      desired_size   = 
    }
  }
}
resource "aws_db_instance" "postgres" {
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "user"
  password          = "password"
  skip_final_snapshot = true
}
