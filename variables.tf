# ---------------------------------------------------------------------------------------------------------------------
# MANDATORY
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "The AWS region to deploy the cluster in (e.g. us-east-1)"
}

variable "environment" {
  description = "The name of the environment the cluster will run in"
}

variable "cluster_name" {
  description = "The name of the Eventstore cluster to create"
}

variable "cluster_vpc_id" {
  description = "Id of the VPC to launch Eventstore in"
}

variable "cluster_azs" {
  type        = list
  description = "Availability zones to place cluster instances in (may be empty if cluster_subnets is specified)"
}

variable "cluster_subnets" {
  type        = list
  description = "A list of subnet id's to place cluster instances in (may be empty if cluster_azs is specified)"
}

variable "key_pair_name" {
  description = "The AWS Key Pair name to use for Evenstore cluster instances"
}

variable "key_pair_publickey" {
  description = "The AWS Key Pair public key  to use for Eventstore instances"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_version" {
  description = "The version of Eventstore to run the cluster on"
  default     = "4.0.3"
}

variable "cluster_size" {
  description = "The desired number of nodes in the Eventstore cluster ASG (quorum size)"
  default     = 3
}

variable "cluster_min_size" {
  description = "The minimum number of nodes in the Eventstore cluster ASG. If set to -1 the value will be calculated based on cluster_size."
  default     = -1
}

variable "cluster_max_size" {
  description = "The maximum number of nodes in the Eventstore cluster ASG. If set to -1 the value will be calculated based on cluster_size."
  default     = -1
}

variable "cluster_dns" {
  description = "DNS name used for node discovery when bringing up Eventstore nodes"
  default     = "cluster.eventstore.net"
}

variable "cluster_allowed_cidr_blocks" {
  type        = list
  description = "A list of CIDR blocks that is allowed access to the Eventstore"
  default     = ["0.0.0.0/0"] # Defaults to everyone and everything
}

variable "cluster_external_ip_type" {
  description = "Advertise cluster instance externally using the private or public instance ip"
  default     = "private"
}

variable "cluster_internal_ip_type" {
  description = "Advertise cluster instance internally using the private or public instance ip"
  default     = "private"
}

variable "cluster_stats_period_sec" {
  description = "The number of seconds between statistics gathers"
  default     = 30
}

variable "instance_ami" {
  description = "The AMI to use for cluster instances (Leave empty to use the latest Ubuntu 16.04 Canonical)"
  default     = ""
}

variable "instance_type" {
  description = "The AWS instance type to use for cluster instances"
  default     = "t2.micro"
}

variable "instance_volume_name_prefix" {
  description = "The name prefix of the additional EBS volumes attached to the cluster instances"
  default     = "/dev/xvd"
}

variable "instance_volume_size" {
  description = "The size of the additional EBS volumes attached to the cluster instances (in gigabytes)"
  default     = "10"
}

variable "instance_volume_encryption" {
  description = "Enable encryption of the additional EBS volumes attached to the cluster instances"
  default     = true
}

variable "instance_volume_protection" {
  description = "Keep EBS volumes after instance termination"
  default     = false
}

variable "instance_timezone" {
  description = "The timezone in which the instance should run"
  default     = "UTC"
}

variable "instance_detailed_monitoring" {
  description = "Enabled detailed monitoring on EC2 instances"
  default     = false
}

variable "log_forwarding_elasticsearch_enabled" {
  description = "Enable log aggregation using fluentbit and eleasticsearch"
  default     = false
}

variable "log_forwarding_elasticsearch_endpoint" {
  description = "The elasticsearch host to send logs to"
  default     = ""
}

variable "log_forwarding_elasticsearch_port" {
  description = "The elasticsearch host port to send logs to"
  default     = 443
}

variable "cloudwatch_agent_enabled" {
  description = "Enable the AWS Cloudwatch Agent to collect additional instance metrics"
  default     = false
}

variable "backups_s3_enabled" {
  description = "Enable backups to S3"
  default     = false
}

variable "backups_s3_setup_script" {
  description = "Script that will be executed during init to setup backups"
  default     = ""
}

variable "scavenging_cron_enabled" {
  description = "Enable scavenging"
  default     = false
}

variable "scavenging_cron_schedules" {
  type        = map
  description = "The cidr block/cron schedule map"
  default     = {}
}

variable "scavenging_cron_eventstore_username" {
  description = "The username used for scavenging"
  default     = "admin"
}

variable "scavenging_cron_eventstore_password" {
  description = "The password used for scavenging"
  default     = "changeit"
}

variable "additional_user_data_enabled" {
  description = "Enable running additional user_data script"
  default     = false
}

variable "additional_user_data_pre_install_script" {
  description = "Pre install user_data script"
  default     = ""
}

variable "additional_user_data_post_install_script" {
  description = "Post install user_data script"
  default     = ""
}

variable "additional_ports" {
  description = "Additional ports to be opened by adding inbound rules to the security group"
  type        = list
  default     = []
}
