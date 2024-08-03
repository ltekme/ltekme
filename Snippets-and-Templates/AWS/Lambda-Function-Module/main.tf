/*########################################################
locals

########################################################*/
locals {
  prefix = lower(replace(replace(var.prefix, " ", "-"), "_", "-"))

  lambda-function-name = "${local.prefix}-${var.name}"

  lambda-handler      = lookup(var.lambda-config, "handler", "lambda_function.lambda_handler")
  lambda-runtime      = lookup(var.lambda-config, "runtime", "python3.12")
  lambda-architecture = lookup(var.lambda-config, "architecture", "arm64")
  lambda-timeout      = lookup(var.lambda-config, "timeout", 300)

  lambda-create_role        = lookup(var.lambda-config, "execution_role", null) == null ? true : false
  lambda-execution-role-arn = local.lambda-create_role == true ? aws_iam_role.this[0].arn : var.lambda-config.execution_role


  cloudwatch-log-group-name = "/aws/lambda/${local.lambda-function-name}"
}

data "aws_caller_identity" "current" {}


/*########################################################
Lambda Function Base Permissions

########################################################*/
resource "aws_iam_role" "this" {
  count = local.lambda-create_role == true ? 1 : 0
  name  = lower("${local.lambda-function-name}-role")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "cloudwatch-logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow",
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
          Resource = "arn:aws:logs:${var.aws-region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch-log-group-name}:*"
        }
      ]
    })
  }

  dynamic "inline_policy" {
    for_each = var.additional-permissions
    content {
      name   = inline_policy.value.name
      policy = jsonencode(inline_policy.value.policy)
    }
  }
}


/*########################################################
Lambda Function

########################################################*/
resource "aws_lambda_function" "this" {
  // User Input Lambda Function
  function_name = local.lambda-function-name
  description   = var.description

  filename         = var.source_code_zip_path
  source_code_hash = filebase64sha256(var.source_code_zip_path)

  handler       = local.lambda-handler
  runtime       = local.lambda-runtime
  architectures = [local.lambda-architecture]

  role = local.lambda-execution-role-arn

  timeout = local.lambda-timeout

  environment {
    variables = var.additional-environment-variables
  }
}


/*########################################################
Lambda Function CloudWatch Logs

########################################################*/
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create-cloudwatch-log-group == true ? 1 : 0
  name              = local.cloudwatch-log-group-name
  retention_in_days = 7
}
