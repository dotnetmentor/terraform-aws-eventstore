# ---------------------------------------------------------------------------------------------------------------------
# MANDATORY
# ---------------------------------------------------------------------------------------------------------------------

variable "enabled" {
  description = "When true, creates resources to enable scavenging"
}

variable "cron_schedules" {
  type        = map
  description = "The cidr block/cron schedule map"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL
# ---------------------------------------------------------------------------------------------------------------------

variable "eventstore_username" {
  description = "The username used for scavenging"
  default     = "admin"
}

variable "eventstore_password" {
  description = "The password used for scavenging"
  default     = "changeit"
}
