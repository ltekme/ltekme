/*########################################################
Terraform Requiements and Provider

########################################################*/
terraform {
  required_version = ">= 1.9.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.57.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.6.2"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Created_by = "Terrafrom"
      Project    = var.project-name
    }
  }
  region = var.aws-region
}


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


/*########################################################
S3 bucket settings OAI

########################################################*/
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


/*########################################################
S3 bucket settings for no OAI

########################################################*/
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