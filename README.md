# terraform-aws-eventstore

Terraform module for bringing up a clustered Eventstore in AWS.

**NOTE: This module is not ready for use in production!!!**

## Additional information

- [Eventstore](https://eventstore.org/)
- [AWS](https://aws.amazon.com/)
- [Terraform](https://www.terraform.io/)

## Resource types

- Auto Scaling Group
- Launch Configuration
- Security Group
- Key Pair

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
