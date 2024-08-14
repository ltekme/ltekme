# Full Terraform IaC

## Setup Bucket and Website content

```hcl
/*########################################################
Terraform Requiements

######################################################## */
terraform {
  required_version = ">= 1.9.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.57.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">=3.6.2"
    }
  }
}


/*########################################################
AWS Terraform Provider

########################################################*/
provider "aws" {
  default_tags {
    tags = {
      Created_by = "Terraform"
      Project    = var.project-name
    }
  }
  region = var.aws-region
}
data "aws_caller_identity" "current" {}


/*########################################################
Terrafrom AWS Project Settings

########################################################*/
variable "project-name" {
  description = "The name of the project"
  type        = string
  default     = "website-on-s3"
}

variable "aws-region" {
  description = "AWS Rrgion code to deploy the resources in"
  type        = string
  default     = "us-east-1"
}


/*########################################################
Bucket - Suffix

########################################################*/
resource "random_string" "website-bucket-suffix" {
  // random suffix for unique bucket name
  length  = 16
  lower   = true
  upper   = false
  special = false
  numeric = true
}


/*########################################################
Bucket

########################################################*/
resource "aws_s3_bucket" "website" {
  // Create a S3 bucket for the website hosting
  bucket        = "${replace(replace(var.project-name, "_", "-"), " ", "-")}-${random_string.website-bucket-suffix.result}"
  force_destroy = true
}


/*########################################################
Bucket - Contents - build

########################################################*/
resource "null_resource" "website-node-build" {
  // Build the web interface from node
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/react-website"
    command     = "npm install && npm run build"
  }
}


/*########################################################
Bucket - Contents - upload

########################################################*/
resource "null_resource" "website-content-sync" {
  // Copy the website folder to the S3 bucket
  provisioner "local-exec" {
    working_dir = "${path.module}/web_interface"
    command     = "aws s3 sync build s3://${aws_s3_bucket.website.id} --delete --region ${var.aws-region}"
  }

  // trigger replace
  lifecycle {
    replace_triggered_by = [null_resource.website-node-build]
  }

  // sync after build and bucket creation
  depends_on = [
    aws_s3_bucket.website,
    resource.null_resource.website-node-build
  ]
}
```

## Host with S3 Static website hosting

```hcl
/*########################################################
Bucket - Website - Disable Public Block

########################################################*/
resource "aws_s3_bucket_public_access_block" "website" {
  // Diable bucket block public access
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


/*########################################################
Bucket - Website - Public Policy

########################################################*/
resource "aws_s3_bucket_policy" "website-public" {
  // Bucket Policy for public access
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.website.arn}/*",
    }],
  })
}


/*########################################################
Bucket - Website - Config Website

########################################################*/
resource "aws_s3_bucket_website_configuration" "website" {
  // Websit hosting config for not using cloudfront
  bucket = aws_s3_bucket.web-website.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}
```

## Host with CloudFront Distribution

```hcl
/*########################################################
CloudFront Distribution - OAC

########################################################*/
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${replace(var.project-name, " ", "-")}-website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


/*########################################################
CloudFront Distribution

########################################################*/
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "s3-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy = "redirect-to-https"

    // Get from console
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" // Managed-CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" // Managed-CORS-S3Origin

    target_origin_id = "s3-website"
  }
  
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}
```
