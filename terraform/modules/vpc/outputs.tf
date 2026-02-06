output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnet_cidrs" {
  value = module.vpc.public_subnets_cidr_blocks
}
