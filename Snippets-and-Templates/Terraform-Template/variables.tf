/*########################################################
Default Variables

########################################################*/
variable "project-name" {
  description = "The name of the project(can only contain letters, numbers, and hyphens)"
  type        = string
  default     = "Template"
  validation {
    condition     = length(regexall("^[a-zA-Z0-9-]+$", var.project-name)) > 0
    error_message = "project-name name must only contain letters, numbers, and hyphens."
  }
}

variable "aws-region" {
  description = "AWS Region code to deploy the resources in"
  type        = string
  default     = "us-east-1"
}
