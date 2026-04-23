variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether image tags are mutable or immutable"
  type        = string
  default     = "IMMUTABLE"
}

variable "keep_last_images" {
  description = "How many tagged images should be kept by the lifecycle policy"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags applied to the repository"
  type        = map(string)
  default     = {}
}