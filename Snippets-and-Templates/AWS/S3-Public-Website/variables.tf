/*########################################################
AWS Project Settings

########################################################*/
variable "project-name" {
  description = "The name of the project(can only contain letters, numbers, and hyphens)"
  type        = string
  default     = "S3-cf-website"
  validation {
    condition     = length(regexall("^[a-zA-Z0-9-]+$", var.project-name)) > 0
    error_message = "project-name name must only contain letters, numbers, and hyphens."
  }
}

variable "aws-region" {
  description = "AWS Rrgion code to deploy the resources in"
  type        = string
  default     = "us-east-1"
}


/*########################################################
Settings

########################################################*/
variable "site-domain" {
  description = "The domain of the website"
  type = string
  default = null
}

variable "setup-CloudFront" {
  description = "Setup cloudfront for website content bucket"
  type = bool
  default = true
}

variable "setup-CloudFront-OAI" {
  description = "Setup CloudFront OAI for S3 bucket to block public access on bucket"
  type = bool
  default = true
  validation {
    condition = !(var.setup-CloudFront-OAI && !var.setup-CloudFront)
    error_message = "Cannot setup CloudFront OAI if setup-CloudFront is false"
  }
}

variable "website-Index-Document" {
  description = "Index Document of Website"
  type = string
  default = "/index.html"
  validation {
    condition = !(split("", var.website-Index-Document)[0] != "/")
    error_message = "website-Index-Document must start with / using abs path"
  }
}

variable "website-Error-Document" {
  description = "Error Document of Website"
  type = string
  default = "/error.html"
  validation {
    condition = !(split("", var.website-Error-Document)[0] != "/")
    error_message = "website-Error-Document must start with / using abs path"
  }
}