variable "name_prefix" {
  description = "Prefix used in IAM resource names"
  type        = string
}

variable "tags" {
  description = "Tags applied to IAM resources"
  type        = map(string)
  default     = {}
}