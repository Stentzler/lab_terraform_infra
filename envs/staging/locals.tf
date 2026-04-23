locals {
  aws_region   = var.aws_region
  environment  = "staging"
  service_name = var.service_name

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