terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.45.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
}

resource "aws_iam_role_policy_attachment" "eventstore" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = var.eventstore_iam_role_name
}

data "local_file" "config" {
  filename = "${path.module}/config.json"
}

data "template_file" "setup" {
  template = file("${path.module}/setup.sh")

  vars = {
    config_json = data.local_file.config.content
    enabled     = var.enabled
  }
}
