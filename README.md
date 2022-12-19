# terraform-aws-eventstore

Terraform module for bringing up a clustered Eventstore in AWS.

**NOTE: This module is not ready for use in production!!!**

**NOTE: Some of the settings have UNSAFE default values!!!**

## Additional information

- [Eventstore](https://eventstore.org/)
- [AWS](https://aws.amazon.com/)
- [Terraform](https://www.terraform.io/)

## Resource types - main module

- Auto Scaling Group
- Launch Configuration
- EBS Volumes
- IAM Role
- IAM Instance Profile
- Security Groups
- Key Pair

## Resource types - s3-backup module

- S3 Bucket
- S3 Bucket Policy
- IAM User
- IAM Access Key

## Resource types - cloudwatch-agent module

- AWS IAM Role Policy Attachment

## Usage

```HCL
provider "aws" {
  version = "~> 1.0.0"
  region  = "eu-west-1"
}

module "eventstore" {
  source = "dotnetmentor/terraform-aws-eventstore"

  name = "my-eventstore"

  # ...

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

## Authors

- [Kristoffer Ahl](https://github.com/kristofferahl)

## License

Apache 2 Licensed. See LICENSE for full details.
