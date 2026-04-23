variable "name_prefix" {
  description = "Prefix used in resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the load balancer and target group will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the internet-facing ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  type        = string
}

variable "app_port" {
  description = "Port on which the application listens on the EC2 instances"
  type        = number
}

variable "health_check_path" {
  description = "HTTP path used for target group health checks"
  type        = string
}

variable "tags" {
  description = "Tags applied to ALB resources"
  type        = map(string)
  default     = {}
}