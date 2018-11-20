provider "aws" {
  version = "~> 1.10.0"
  region  = "${var.bucket_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 bucket for backups
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "backup" {
  count = "${var.enabled ? 1 : 0}"

  bucket = "${var.bucket_name}"
  acl    = "private"

  force_destroy = false

  tags {
    Name    = "${var.bucket_name}"
    Cluster = "${var.cluster_name}"
  }
}

resource "aws_s3_bucket_policy" "backup" {
  count = "${var.enabled ? 1 : 0}"

  bucket = "${aws_s3_bucket.backup.id}"
  policy = "${element(data.template_file.bucket_policy.*.rendered, count.index)}"
}

data "template_file" "bucket_policy" {
  count = "${var.enabled ? 1 : 0}"

  template = "${file("${path.module}/bucket-policy.json")}"

  vars {
    iam_user_arn  = "${aws_iam_user.backup.arn}"
    s3_bucket_arn = "${aws_s3_bucket.backup.arn}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM user for backups/restore
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_user" "backup" {
  count = "${var.enabled ? 1 : 0}"

  name = "${var.bucket_name}-user"
  path = "/"
}

resource "aws_iam_access_key" "backup" {
  count = "${var.enabled ? 1 : 0}"

  user = "${aws_iam_user.backup.name}"
}
