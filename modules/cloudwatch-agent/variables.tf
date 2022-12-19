# ---------------------------------------------------------------------------------------------------------------------
# MANDATORY
# ---------------------------------------------------------------------------------------------------------------------

variable "enabled" {
  description = "When true, creates resources to enable the AWS Cloudwatch Agent"
}

variable "eventstore_iam_role_name" {
  description = "The role name associated with the Eventstore instances"
}
