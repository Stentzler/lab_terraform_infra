variable "aws_region" {
  description = "AWS region for the staging environment"
  type        = string
}

variable "service_name" {
  description = "Logical name of the service"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the Auto Scaling Group"
  type        = string
}

variable "app_port" {
  description = "Port exposed by the application container on the EC2 instance"
  type        = number
}

variable "health_check_path" {
  description = "HTTP path used by the load balancer health check"
  type        = string
  default     = "/health"
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

variable "extra_tags" {
  description = "Additional tags merged into the common tags"
  type        = map(string)
  default     = {}
}