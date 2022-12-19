terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.45.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 bucket for backups
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "backup" {
  count = var.enabled ? 1 : 0

  bucket = var.bucket_name
  acl    = "private"

  force_destroy = false

  tags = {
    Name    = var.bucket_name
    Cluster = var.cluster_name
  }
}

resource "aws_s3_bucket_policy" "backup" {
  count = var.enabled ? 1 : 0

  bucket = aws_s3_bucket.backup.0.id
  policy = element(data.template_file.bucket_policy.*.rendered, count.index)
}

data "template_file" "bucket_policy" {
  count = var.enabled ? 1 : 0

  template = file("${path.module}/bucket-policy.json")

  vars = {
    iam_user_arn  = aws_iam_user.backup.0.arn
    s3_bucket_arn = aws_s3_bucket.backup.0.arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM user for backups/restore
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_user" "backup" {
  count = var.enabled ? 1 : 0

  name = "${var.bucket_name}-user"
  path = "/"
}

resource "aws_iam_access_key" "backup" {
  count = var.enabled ? 1 : 0

  user = aws_iam_user.backup.0.name
}
