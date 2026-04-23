variable "aws_region" {
  description = "AWS region where the Terraform state buckets will be created"
  type        = string
}

variable "project_name" {
  description = "Project or service name used in resource naming"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all bootstrap resources"
  type        = map(string)
  default     = {}
}