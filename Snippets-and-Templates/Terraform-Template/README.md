# Template for AWS Terraform

[↩️ go back](../README.md)

A folder containing the base code blocks for aws with terraform

## Quick

```hcl
/*########################################################
Terraform Requiements

########################################################*/
terraform {
  required_version = ">= 1.9.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.57.0"
    }
  }
}


/*########################################################
AWS Terraform Provider and Data

########################################################*/
provider "aws" {
  default_tags {
    tags = {
      Created_by = "Terrafrom"
      Project    = "${var.project-name}"
    }
  }
  region = var.aws-region
}
data "aws_caller_identity" "current" {}


/*########################################################
Default Variables

########################################################*/
variable "project-name" {
  description = "The name of the project(can only contain letters, numbers, and hyphens)"
  type        = string
  default     = "Tamplate"
}

variable "aws-region" {
  description = "AWS Region code to deploy the resources in"
  type        = string
  default     = "us-east-1"
}
```