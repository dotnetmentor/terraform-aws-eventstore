output "bucket_name" {
  value = "${element(concat(aws_s3_bucket.backup.*.id, list("")), 0)}"
}

output "bucket_region" {
  value = "${var.bucket_region}"
}

output "iam_access_key_id" {
  value = "${element(concat(aws_iam_access_key.backup.*.id, list("")), 0)}"
}

output "iam_secret_access_key" {
  value     = "${element(concat(aws_iam_access_key.backup.*.secret, list("")), 0)}"
  sensitive = true
}
