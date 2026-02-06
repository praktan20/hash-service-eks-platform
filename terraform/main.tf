module "vpc" {
  source = "./modules/vpc"

  name           = "hash-service-vpc"
  cidr           = "10.0.0.0/16"
  azs            = ["us-east-2a", "us-east-2b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "hash-service"
  cluster_version = "1.32"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets
}

module "rds" {
  source = "./modules/rds"

  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnets
  allowed_cidrs  = module.vpc.public_subnet_cidrs
}

module "iam" {
  source = "./modules/iam"
}
