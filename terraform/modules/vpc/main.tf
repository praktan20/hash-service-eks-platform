module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.cidr

  azs            = var.azs
  public_subnets = var.public_subnets
  private_subnets = []

  enable_nat_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
  map_public_ip_on_launch = true
  create_igw              = true

  tags = {
    Terraform   = "true"
    CostModel  = "minimum"
  }
}
