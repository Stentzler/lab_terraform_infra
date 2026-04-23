output "vpc_id" {
  description = "VPC ID of the staging environment"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs of the staging environment"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs of the staging environment"
  value       = module.network.private_subnet_ids
}

output "alb_dns_name" {
  description = "Public DNS name of the staging ALB"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for the staging service"
  value       = module.ecr.repository_url
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name for the staging service"
  value       = module.service_compute.autoscaling_group_name
}