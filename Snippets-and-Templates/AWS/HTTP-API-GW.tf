
/*########################################################
API Gateway

########################################################*/
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-API"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = replace(replace("${var.project_name}_API_Stage", " ", "_"), "-", "_")
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main-api_gateway.arn
    format = jsonencode({
      requestId               = "$context.requestId",
      ip                      = "$context.identity.sourceIp",
      requestTime             = "$context.requestTime",
      httpMethod              = "$context.httpMethod",
      status                  = "$context.status",
      protocol                = "$context.protocol",
      integrationErrorMessage = "$context.integrationErrorMessage",
      errorMessage            = "$context.error.message"
    })
  }
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  description = "${var.project_name}-API-Deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.some_route
  ]
}


/*########################################################
API Gateway Log

########################################################*/
resource "aws_cloudwatch_log_group" "main-api_gateway" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.main.id}"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "main-api_gateway" {
  cloudwatch_role_arn = aws_iam_role.main-api_gateway.arn
}

resource "aws_iam_role" "main-api_gateway" {
  name = replace(replace("${var.project_name}-Main-API-Gateway-Role", " ", "_"), "-", "_")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
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
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents",
          ],
          Resource = ["*"]
        }
      ]
    })
  }
}


/*########################################################
API Gateway Resource

Path: /some_route

########################################################*/
resource "aws_apigatewayv2_route" "some_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /some_route"
  target    = "integrations/${aws_apigatewayv2_integration.some_route.id}"
}

resource "aws_apigatewayv2_integration" "some_route" {
  api_id               = aws_apigatewayv2_api.main.id
  passthrough_behavior = "WHEN_NO_MATCH"
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.main.invoke_arn
}

// Lambda Permissions
resource "aws_lambda_permission" "submit_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws-region}:${data.aws_caller_identity.current.account_id}:*/*/*"
}






/*########################################################
Supporting Resources

Not Part of Template

########################################################*/
variable "project_name" {
  type        = string
  description = "Project Name"
}

variable "aws-region" {
  type        = string
  description = "AWS Region"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "main" {
  function_name = "${var.project_name}-Main"
  description   = "Template Lambda Function"
  role          = ""
}
