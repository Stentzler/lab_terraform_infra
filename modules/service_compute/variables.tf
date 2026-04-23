variable "name_prefix" {
  description = "Prefix used in resource names"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where the Auto Scaling Group instances will run"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "Security group ID attached to the EC2 instances"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name attached to the EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN used by the Auto Scaling Group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the launch template"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
}

variable "repository_url" {
  description = "ECR repository URL used for docker pull"
  type        = string
}

variable "container_image_tag" {
  description = "Image tag to run on the EC2 instances"
  type        = string
  default     = "latest"
}

variable "app_port" {
  description = "Port exposed by the application container"
  type        = number
}

variable "aws_region" {
  description = "AWS region where the service runs"
  type        = string
}

variable "ami_ssm_parameter_name" {
  description = "SSM public parameter name that resolves to the AMI ID"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "tags" {
  description = "Tags applied to compute resources"
  type        = map(string)
  default     = {}
}