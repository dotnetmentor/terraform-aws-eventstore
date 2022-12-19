output "cloudwatch_agent_setup_script" {
  value = data.template_file.setup.rendered
}
