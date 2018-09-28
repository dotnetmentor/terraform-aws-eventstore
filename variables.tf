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

variable "cluster_size" {
  description = "The desired number of nodes in the Eventstore cluster (quorum size)"
}

variable "cluster_vpc_id" {
  description = "Id of the VPC to launch Eventstore in"
}

variable "cluster_azs" {
  type        = "list"
  description = "Availability zones to place cluster instances in (may be empty if cluster_subnets is specified)"
}

variable "cluster_subnets" {
  type        = "list"
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

variable "cluster_dns" {
  description = "DNS name used for node discovery when bringing up Eventstore nodes"
  default     = "cluster.eventstore.net"
}

variable "cluster_allowed_cidr_blocks" {
  type        = "list"
  description = "A list of CIDR blocks that is allowed access to the Eventstore"
  default     = ["0.0.0.0/0"]                                                    # Defaults to everyone and everything
}

variable "cluster_external_ip_type" {
  description = "Advertise cluster instance externally using the private or public instance ip"
  default     = "private"
}

variable "cluster_internal_ip_type" {
  description = "Advertise cluster instance internally using the private or public instance ip"
  default     = "private"
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
