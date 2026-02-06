output "eks_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "eks_admin_role" {
  value = module.iam.role_arn
}
