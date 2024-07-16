output "lambda_function" {
  value = aws_lambda_function.this
}

output "lambda_role" {
  value = aws_iam_role.this
}

output "cloudwatch" {
  value = aws_cloudwatch_log_group.this
}