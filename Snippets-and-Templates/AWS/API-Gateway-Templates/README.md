# API Gateway Templates

Snippets of AWS API Gateway Terraform Code Blocks

[↩️ go back](../)

## Table Of Contents

- [API Gateway Templates](#api-gateway-templates)
  - [Table Of Contents](#table-of-contents)
  - [HTTP API Gateway](#http-api-gateway)
    - [API](#api)
    - [Stage](#stage)
    - [Deployent](#deployent)
  - [API Gatewat Logs](#api-gatewat-logs)
    - [CloudWatch Log Group](#cloudwatch-log-group)
    - [API Gateway Account](#api-gateway-account)
      - [Account](#account)
      - [Account Permission](#account-permission)
  - [API Gateway Resources](#api-gateway-resources)
    - [Route](#route)
    - [Integration](#integration)
    - [Lambda Permission](#lambda-permission)
  - [Complete File](#complete-file)

## HTTP API Gateway

### API

```tf
*########################################################
API Gateway - API

########################################################*/
resource "aws_apigatewayv2_api" "main" {
  name          = "${ var.project-name}-API"
  protocol_type = "HTTP"
}
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api)

### Stage

```tf
/*########################################################
API Gateway - Stage

########################################################*/
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = replace(replace("${var.project-name}_API_Stage", " ", "_"), "-", "_")
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
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage)

### Deployent

```tf
/*########################################################
API Gateway - Deployment

########################################################*/
resource "aws_apigatewayv2_deployment" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  description = "${ var.project-name}-API-Deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.some_route
  ]
}
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_deployment)

## API Gatewat Logs

### CloudWatch Log Group

```tf
/*########################################################
API Gateway Log - Log Group

########################################################*/
resource "aws_cloudwatch_log_group" "main-api_gateway" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.main.id}"
  retention_in_days = 7
}
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)

### API Gateway Account

#### Account

```tf
resource "aws_api_gateway_account" "main-api_gateway" {
  cloudwatch_role_arn = aws_iam_role.main-api_gateway.arn
}
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account)

#### Account Permission

```tf
resource "aws_iam_role" "main-api_gateway" {
  name = replace(replace("${ var.project-name}-Main-API-Gateway-Role", " ", "_"), "-", "_")
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
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)

## API Gateway Resources

### Route

```tf
/*########################################################
API Gateway Resource - Route

Path: /some_route

########################################################*/
resource "aws_apigatewayv2_route" "some_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /some_route"
  target    = "integrations/${aws_apigatewayv2_integration.some_route.id}"
}
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route)

### Integration

```tf
// Lambda Integration
resource "aws_apigatewayv2_integration" "some_route" {
  api_id               = aws_apigatewayv2_api.main.id
  passthrough_behavior = "WHEN_NO_MATCH"
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.main.invoke_arn
}
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration)

### Lambda Permission

```tf
// Lambda Permissions
resource "aws_lambda_permission" "submit_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws-region}:${data.aws_caller_identity.current.account_id}:*/*/*"
}
```

Reference Link: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)

## Complete File

[HTTP-API-GW.tf](HTTP-API-GW.tf)
