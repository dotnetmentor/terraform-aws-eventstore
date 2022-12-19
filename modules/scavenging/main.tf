terraform {
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

data "template_file" "setup" {
  template = file("${path.module}/setup.sh")

  vars = {
    cidr_blocks         = replace(replace(replace(jsonencode(keys(var.cron_schedules)), ",", " "), "[", ""), "]", "")
    cron_schedules      = replace(replace(replace(jsonencode(values(var.cron_schedules)), ",", " "), "[", ""), "]", "")
    eventstore_username = var.eventstore_username
    eventstore_password = var.eventstore_password
  }
}
