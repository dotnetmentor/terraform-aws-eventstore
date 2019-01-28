data "template_file" "setup" {
  template = "${file("${path.module}/setup.sh")}"

  vars = {
    cidr_blocks    = "${replace(replace(replace(jsonencode(keys(var.cron_schedules)), ",", " "), "[", ""), "]", "")}"
    cron_schedules = "${replace(replace(replace(jsonencode(values(var.cron_schedules)), ",", " "), "[", ""), "]", "")}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
}
