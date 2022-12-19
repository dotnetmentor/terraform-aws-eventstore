output "bucket_name" {
  value = element(concat(aws_s3_bucket.backup.*.id, tolist([""])), 0)
}

output "bucket_region" {
  value = var.bucket_region
}

output "iam_access_key_id" {
  value     = element(concat(aws_iam_access_key.backup.*.id, tolist([""])), 0)
  sensitive = true
}

output "iam_secret_access_key" {
  value     = element(concat(aws_iam_access_key.backup.*.secret, tolist([""])), 0)
  sensitive = true
}
