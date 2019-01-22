# ---------------------------------------------------------------------------------------------------------------------
# MANDATORY
# ---------------------------------------------------------------------------------------------------------------------

variable "enabled" {
  description = "When true, creates resources to enable backups"
}

variable "bucket_region" {
  description = "The AWS region to create the S3 backup bucket in (e.g. us-east-1)"
}

variable "bucket_name" {
  description = "The name of the S3 backup bucket"
}

variable "cluster_name" {
  description = "The name of the Eventstore cluster that uses the backup module"
}
