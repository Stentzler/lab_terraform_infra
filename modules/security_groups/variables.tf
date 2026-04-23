variable "name_prefix" {
  description = "Prefix used in resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

variable "app_port" {
  description = "Application port exposed by the EC2 instances"
  type        = number
}

variable "tags" {
  description = "Tags applied to the security groups"
  type        = map(string)
  default     = {}
}