# S3 Public Website with CloudFront

Snippets of S3 Public Website with CloudFront

[↩️ go back](../)

## Table of Contents

- [S3 Public Website with CloudFront](#s3-public-website-with-cloudfront)
  - [Table of Contents](#table-of-contents)
  - [Variables](#variables)
  - [Bucket](#bucket)
    - [Properity for Setup With CloudFront and OAI](#properity-for-setup-with-cloudfront-and-oai)
    - [Property for Setup With CloudFront or OAI](#property-for-setup-with-cloudfront-or-oai)
  - [CloudFront](#cloudfront)
  - [Outputs](#outputs)

## Variables

```hcl/*########################################################
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
```

Reference Links:

- [https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation](https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation)

## Bucket

```hcl
/*########################################################
S3 bucket for website content

########################################################*/
locals {
    s3 = {
        bucket-name = "${var.site-domain == null ? lower(replace(var.project-name, " ", "-")) : lower(replace(var.site-domain, ".", "-"))}-${random_string.bucket-webiste_content-suffix.result}"
    }
}

resource "aws_s3_bucket" "webiste_content" {
  // Create a S3 bucket website content
  bucket        = local.s3.bucket-name
  force_destroy = true
}

resource "random_string" "bucket-webiste_content-suffix" {
  // random suffix for unique bucket name
  length  = 12
  lower   = true
  upper   = false
  special = false
  numeric = true
}
```

Reference Links:

- [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)

### Properity for Setup With CloudFront and OAI

```hcl
resource "aws_s3_bucket_policy" "webiste_content-oai" {
  count = var.setup-CloudFront || var.setup-CloudFront-OAI ? 1 : 0
  // Bucket Policy for CloudFront OAI
  bucket = aws_s3_bucket.webiste_content.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {AWS = ["${aws_cloudfront_origin_access_identity.webiste_content-bucket-webiste_content[0].iam_arn}"]}
      Action   = "s3:GetObject",
      Resource = "${aws_s3_bucket.webiste_content.arn}/*",
    }],
  })
}
```

Reference Links:

- [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)

### Property for Setup With CloudFront or OAI

```hcl
resource "aws_s3_bucket_public_access_block" "webiste_content" {
  // Diable bucket block public access
  count                   = !var.setup-CloudFront || !var.setup-CloudFront-OAI ? 1 : 0
  bucket                  = aws_s3_bucket.webiste_content.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "webiste_content" {
  // Bucket polipcy for no Cloudfront
  count  = !var.setup-CloudFront || !var.setup-CloudFront-OAI ? 1 : 0
  bucket = aws_s3_bucket.webiste_content.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.webiste_content.arn}/*",
    }],
  })
}

resource "aws_s3_bucket_website_configuration" "webiste_content" {
  // Websit hosting config for not using cloudfront
  count  = !var.setup-CloudFront || !var.setup-CloudFront-OAI ? 1 : 0
  bucket = aws_s3_bucket.webiste_content.id
  
  index_document {
    suffix = var.website-Index-Document
  }
  dynamic "error_document" {
    for_each = var.website-Error-Document != null ? [0] : []
    content {
      key = var.website-Error-Document
    }
  }
}
```

Reference Links:

- [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration)
- [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)
- [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)

## CloudFront

```hcl
/*########################################################
CloudFront for S3 Bucket

########################################################*/
/*########################################################
CloudFront for S3 Bucket

########################################################*/
locals {
  cloudfront = {
    bucket-origin-id = "S3-${aws_s3_bucket.webiste_content.bucket_regional_domain_name}"
  }
}
resource "aws_cloudfront_origin_access_identity" "webiste_content-bucket-webiste_content" {
  count = var.setup-CloudFront && var.setup-CloudFront-OAI ? 1 : 0
}

resource "aws_cloudfront_distribution" "webiste_content" {
  count = var.setup-CloudFront ? 1 : 0

  enabled  = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // bucket origin
  origin {
    domain_name = var.setup-CloudFront-OAI ? aws_s3_bucket.webiste_content.bucket_regional_domain_name : aws_s3_bucket_website_configuration.webiste_content[0].website_endpoint
    origin_id = local.cloudfront.bucket-origin-id
    dynamic "s3_origin_config" {
      for_each = var.setup-CloudFront-OAI ? [0]: []
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.webiste_content-bucket-webiste_content[0].cloudfront_access_identity_path
      }
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy = "redirect-to-https"

    // Get from console
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" // Managed-CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" // Managed-CORS-S3Origin

    target_origin_id = local.cloudfront.bucket-origin-id
  }

  // 404 and 403 response for bucket
  dynamic "custom_error_response" {
    for_each = var.setup-CloudFront-OAI && var.website-Error-Document != null ? [0] : []
    content {
      error_code = 404
      response_code = 404
      response_page_path = var.website-Error-Document
    }
  }
  dynamic "custom_error_response" {
    for_each = var.setup-CloudFront-OAI && var.website-Error-Document != null ? [0] : []
    content {
      error_code = 403
      response_code = 403
      response_page_path = var.website-Error-Document
    }
  }
}
```

Reference Links:

- [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)

## Outputs

```hcl
/*########################################################
Terraform Outputs

########################################################*/
output "s3-bucket-name" {
  value = aws_s3_bucket.webiste_content.bucket
}

output "cloudfront-endpoint" {
  value = var.setup-CloudFront ? "https://${aws_cloudfront_distribution.webiste_content[0].domain_name}/" : null
}

output "s3-bucket-website" {
  value = var.setup-CloudFront && !var.setup-CloudFront-OAI ? aws_s3_bucket_website_configuration.webiste_content[0].website_endpoint : null
}
```
