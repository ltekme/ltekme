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
