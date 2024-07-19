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
