/*########################################################
Required Variables

########################################################*/
variable "aws-region" {
  description = "AWS Rrgion code to deploy the resources in"
  type        = string
}

variable "prefix" {
  description = "Prefix to be added to all resources"
  type        = string
}

variable "source_code_zip_path" {
  description = "Path to the source code zip of the lambda function"
  type        = string
}

variable "name" {
  description = "Name of the lambda function"
  type        = string
}


/*########################################################
Optional Variables

########################################################*/
variable "description" {
  description = "Description of the lambda function"
  type        = string
  default     = ""
}

variable "lambda-config" {
  description = "Map of lambda function configurations"
  type        = map(string)
  default     = {}
}

variable "additional-permissions" {
  description = "List of additional permissions to be added to the lambda function"
  type = list(object({
    name   = string
    policy = any
  }))
  default = []
}

variable "create-cloudwatch-log-group" {
  description = "Create CloudWatch Logs for the lambda function"
  type        = bool
  default     = true
}

variable "additional-environment-variables" {
  description = "Additional environment variables to be added to the lambda function"
  type        = map(string)
  default     = {} 
}