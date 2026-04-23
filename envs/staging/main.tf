module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
  app_port    = var.app_port
  tags        = local.common_tags
}

module "iam_service" {
  source = "../../modules/iam_service"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name      = local.name_prefix
  image_tag_mutability = "MUTABLE"
  keep_last_images     = var.keep_last_images
  tags                 = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  app_port              = var.app_port
  health_check_path     = var.health_check_path
  tags                  = local.common_tags
}

module "service_compute" {
  source = "../../modules/service_compute"

  name_prefix           = local.name_prefix
  subnet_ids            = module.network.private_subnet_ids
  ec2_security_group_id = module.security_groups.ec2_security_group_id
  instance_profile_name = module.iam_service.instance_profile_name
  target_group_arn      = module.alb.target_group_arn
  instance_type         = var.instance_type
  asg_min_size          = var.asg_min_size
  asg_desired_capacity  = var.asg_desired_capacity
  asg_max_size          = var.asg_max_size
  repository_url        = module.ecr.repository_url
  container_image_tag   = var.container_image_tag
  app_port              = var.app_port
  aws_region            = var.aws_region
  tags                  = local.common_tags
}