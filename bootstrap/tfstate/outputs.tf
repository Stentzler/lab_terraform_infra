output "staging_state_bucket_name" {
  description = "S3 bucket name for staging Terraform state"
  value       = aws_s3_bucket.tfstate_staging.bucket
}

output "prod_state_bucket_name" {
  description = "S3 bucket name for prod Terraform state"
  value       = aws_s3_bucket.tfstate_prod.bucket
}