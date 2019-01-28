# ---------------------------------------------------------------------------------------------------------------------
# MANDATORY
# ---------------------------------------------------------------------------------------------------------------------

variable "enabled" {
  description = "When true, creates resources to enable scavenging"
}

variable "cron_schedules" {
  type        = "map"
  description = "The cidr block/cron schedule map"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL
# ---------------------------------------------------------------------------------------------------------------------

variable "admin_username" {
  description = "The admin username to use for scavenging"
  default     = "admin"
}

variable "admin_password" {
  description = "The admin password to use for scavenging"
  default     = "changeit"
}
