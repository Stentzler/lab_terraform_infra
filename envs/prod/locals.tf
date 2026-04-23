locals {
  aws_region   = "us-east-1"
  environment  = "prod"
  service_name = "lab-cicd-pipeline"

  name_prefix = "${local.service_name}-${local.environment}"

  common_tags = merge(
    {
      project     = local.service_name
      environment = local.environment
      managed_by  = "terraform"
      repository  = "infra-service"
    },
    var.extra_tags
  )
}