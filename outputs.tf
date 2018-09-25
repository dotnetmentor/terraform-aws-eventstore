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
