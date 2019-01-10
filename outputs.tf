output "autoscaling_group_name" {
  description = "Name of the autoscaling group used by Eventstore"
  value       = "${aws_autoscaling_group.eventstore.name}"
}

output "cluster_dns" {
  description = "DNS name used for node discovery when bringing up Eventstore nodes"
  value       = "${var.cluster_dns}"
}

output "key_pair_name" {
  description = "Name of the AWS Key Pair associated with the Eventstore instances"
  value       = "${aws_key_pair.deployer.key_name}"
}

output "backups_iam_access_key_id" {
  description = "AWS IAM access key id used for backups"
  value       = "${module.backups.iam_access_key_id}"
  sensitive   = true
}

output "backups_iam_secret_access_key" {
  description = "AWS IAM secret access key used for backups"
  value       = "${module.backups.iam_secret_access_key}"
  sensitive   = true
}
