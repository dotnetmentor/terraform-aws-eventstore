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
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

locals {
  full_cluster_name = "${var.cluster_name}-${var.environment}-eventstore"
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY PAIR USED FOR EVENTSTORE INSTANCES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_key_pair" "deployer" {
  key_name   = var.key_pair_name
  public_key = var.key_pair_publickey
}

# ---------------------------------------------------------------------------------------------------------------------
# ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "eventstore" {
  name                 = "${local.full_cluster_name}-asg"
  launch_configuration = aws_launch_configuration.eventstore.id

  desired_capacity = var.cluster_size
  min_size         = var.cluster_min_size == -1 ? (floor(var.cluster_size / 2) + 1) : var.cluster_min_size
  max_size         = var.cluster_max_size == -1 ? (var.cluster_size * 2) : var.cluster_min_size

  vpc_zone_identifier = var.cluster_subnets

  termination_policies = [
    "Default",
  ]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = [
    {
      key                 = "Name"
      value               = local.full_cluster_name
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

locals {
  ebs_optimized = {
    "t2.large" = true
  }
}

resource "aws_iam_role" "eventstore" {
  name               = local.full_cluster_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "eventstore" {
  name = local.full_cluster_name
  role = aws_iam_role.eventstore.name
}

resource "aws_launch_configuration" "eventstore" {
  name_prefix          = "${local.full_cluster_name}-lc"
  image_id             = var.instance_ami != "" ? var.instance_ami : data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.eventstore.id

  security_groups = [aws_security_group.eventstore.id]
  key_name        = var.key_pair_name

  user_data = data.template_file.eventstore_init.rendered

  enable_monitoring = var.instance_detailed_monitoring

  ebs_optimized = lookup(local.ebs_optimized, var.instance_type, false)

  ebs_block_device {
    device_name           = "${var.instance_volume_name_prefix}b"
    volume_size           = var.instance_volume_size
    volume_type           = "gp2"
    encrypted             = var.instance_volume_encryption
    delete_on_termination = var.instance_volume_protection ? false : true
  }

  ebs_block_device {
    device_name           = "${var.instance_volume_name_prefix}c"
    volume_size           = var.instance_volume_size
    volume_type           = "gp2"
    encrypted             = var.instance_volume_encryption
    delete_on_termination = var.instance_volume_protection ? false : true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "eventstore_init" {
  template = file("${path.module}/user_data.sh")

  vars = {
    environment      = var.environment
    cluster_version  = var.cluster_version
    cluster_size     = var.cluster_size
    cluster_dns      = var.cluster_dns
    external_ip_type = var.cluster_external_ip_type == "private" ? "local" : "public"
    internal_ip_type = var.cluster_internal_ip_type == "private" ? "local" : "public"
    stats_period_sec = var.cluster_stats_period_sec

    instance_timezone = var.instance_timezone

    log_forwarding_elasticsearch_enabled  = var.log_forwarding_elasticsearch_enabled ? true : false
    log_forwarding_elasticsearch_endpoint = var.log_forwarding_elasticsearch_endpoint
    log_forwarding_elasticsearch_port     = var.log_forwarding_elasticsearch_port

    cloudwatch_agent_enabled      = var.cloudwatch_agent_enabled ? true : false
    cloudwatch_agent_setup_script = module.cloudwatch_agent.cloudwatch_agent_setup_script

    backups_s3_enabled               = var.backups_s3_enabled ? true : false
    backups_s3_setup_script          = var.backups_s3_setup_script
    backups_s3_bucket_name           = var.backups_s3_enabled ? module.backups.bucket_name : ""
    backups_s3_bucket_region         = var.backups_s3_enabled ? module.backups.bucket_region : ""
    backups_s3_aws_access_key_id     = var.backups_s3_enabled ? module.backups.iam_access_key_id : ""
    backups_s3_aws_secret_access_key = var.backups_s3_enabled ? module.backups.iam_secret_access_key : ""

    scavenging_cron_enabled      = var.scavenging_cron_enabled ? true : false
    scavenging_cron_setup_script = module.scavenging.cron_setup_script

    additional_user_data_enabled             = var.additional_user_data_enabled ? true : false
    additional_user_data_pre_install_script  = var.additional_user_data_pre_install_script
    additional_user_data_post_install_script = var.additional_user_data_post_install_script
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "eventstore" {
  name   = "${local.full_cluster_name}-sg"
  vpc_id = var.cluster_vpc_id

  tags = {
    Name        = "${local.full_cluster_name}-sg"
    Environment = var.environment
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh_external" {
  type = "ingress"

  description = "SSH (External)"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.cluster_allowed_cidr_blocks

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "client_tcp_external" {
  type = "ingress"

  description = "Clients TCP (External)"
  from_port   = 1113
  to_port     = 1113
  protocol    = "tcp"
  cidr_blocks = var.cluster_allowed_cidr_blocks

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "client_http_external" {
  type = "ingress"

  description = "Clients HTTP (External)"
  from_port   = 2113
  to_port     = 2113
  protocol    = "tcp"
  cidr_blocks = var.cluster_allowed_cidr_blocks

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "tcp_internal_1112" {
  type = "ingress"

  description = "TCP (Internal)"
  from_port   = 1112
  to_port     = 1112
  protocol    = "tcp"
  self        = true

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "tcp_internal_1113" {
  type = "ingress"

  description = "TCP (Internal)"
  from_port   = 1113
  to_port     = 1113
  protocol    = "tcp"
  self        = true

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "tcp_internal_2112" {
  type = "ingress"

  description = "TCP (Internal)"
  from_port   = 2112
  to_port     = 2112
  protocol    = "tcp"
  self        = true

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "tcp_internal_2113" {
  type = "ingress"

  description = "TCP (Internal)"
  from_port   = 2113
  to_port     = 2113
  protocol    = "tcp"
  self        = true

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "additional_open_ports" {
  count = length(var.additional_ports)
  type  = "ingress"

  description = "Added by terraform-aws-eventstore"
  from_port   = element(var.additional_ports, count.index)
  to_port     = element(var.additional_ports, count.index)
  protocol    = "tcp"
  cidr_blocks = var.cluster_allowed_cidr_blocks

  security_group_id = aws_security_group.eventstore.id
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  type = "egress"

  description = "Allow all outgoing"
  from_port   = -1
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.eventstore.id
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKUPS
# ---------------------------------------------------------------------------------------------------------------------

module "backups" {
  source = "./modules/s3-backup"

  providers = {
    aws      = aws
    template = template
  }

  enabled       = var.backups_s3_enabled
  bucket_region = var.region
  bucket_name   = "${local.full_cluster_name}-backups"
  cluster_name  = local.full_cluster_name
}

# ---------------------------------------------------------------------------------------------------------------------
# SCAVENGING
# ---------------------------------------------------------------------------------------------------------------------

module "scavenging" {
  source = "./modules/scavenging"

  providers = {
    template = template
  }

  enabled             = var.scavenging_cron_enabled
  cron_schedules      = var.scavenging_cron_schedules
  eventstore_username = var.scavenging_cron_eventstore_username
  eventstore_password = var.scavenging_cron_eventstore_password
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH AGENT
# ---------------------------------------------------------------------------------------------------------------------

module "cloudwatch_agent" {
  source = "./modules/cloudwatch-agent"

  providers = {
    aws   = aws
    local = local
  }

  enabled                  = var.cloudwatch_agent_enabled
  eventstore_iam_role_name = aws_iam_role.eventstore.name
}
