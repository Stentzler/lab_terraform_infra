
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        managed_by = "terraform"
        stack      = "bootstrap"
      },
      var.tags
    )
  }
}

locals {
  staging_bucket_name = "${var.project_name}-tfstate-staging"
  prod_bucket_name    = "${var.project_name}-tfstate-prod"
}

resource "aws_s3_bucket" "tfstate_staging" {
  bucket = local.staging_bucket_name
}

resource "aws_s3_bucket" "tfstate_prod" {
  bucket = local.prod_bucket_name
}

resource "aws_s3_bucket_versioning" "tfstate_staging" {
  bucket = aws_s3_bucket.tfstate_staging.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_prod" {
  bucket = aws_s3_bucket.tfstate_prod.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_staging" {
  bucket = aws_s3_bucket.tfstate_staging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_prod" {
  bucket = aws_s3_bucket.tfstate_prod.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_staging" {
  bucket = aws_s3_bucket.tfstate_staging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "tfstate_prod" {
  bucket = aws_s3_bucket.tfstate_prod.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}