output "cron_setup_script" {
  value = var.enabled ? data.template_file.setup.rendered : ""
}
