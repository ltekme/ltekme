# User Input Lambda Function Module

This is just a lambda function rapped in a terraform module for a cleaner root module. Read Path: [https://github.com/ltekme/ltekme/tree/main/Snippets-and-Templates/AWS/Lambda-Function-Module](https://github.com/ltekme/ltekme/tree/main/Snippets-and-Templates/AWS/Lambda-Function-Module)

## Inputs

| arg                              | default | description                                                         | type                                    |
| -------------------------------- | ------- | ------------------------------------------------------------------- | --------------------------------------- |
| aws-region                       |         | AWS Rrgion code to deploy the resources in                          | string                                  |
| prefix                           |         | Prefix to be added to all resources                                 | string                                  |
| source_code_zip_path             |         | Path to the source code zip of the lambda function                  | string                                  |
| name                             |         | Name of the lambda function                                         | string                                  |
| description                      | ""      | Description of the lambda function                                  | string                                  |
| lambda-config                    | {}      | Map of lambda function configurations                               | map(string)                             |
| additional-permissions           | []      | List of additional permissions to be added to the lambda function   | list(object({name=string, policy=any})) |
| create-cloudwatch-log-group      | true    | Create CloudWatch Logs for the lambda function                      | bool                                    |
| additional-environment-variables | {}      | Additional environment variables to be added to the lambda function | map(string)                             |

### lambda-config

| arg                            | default                          | description                                           |
| ------------------------------ | -------------------------------- | ----------------------------------------------------- |
| `lambda-config.handler`        | "lambda_function.lambda_handler" | The lambda function handler                           |
| `lambda-config.runtime`        | "python3.12"                     | The runtime of the lambda function                    |
| `lambda-config.architecture`   | "arm64"                          | The architecture of the lambda function               |
| `lambda-config.timeout`        | 3                                | Lambda timeout in seconds                             |
| `lambda-config.execution_role` | null                             | The execution role which the lambda function will use |

Map of Lambda configurations. Example

```hcl
module "user_input_lambda" {
  source = "./modules/lambda"
  lambda-config = {
    handler        = "main.handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    timeout        = 3
    execution_role = var.lambda_function-user_input-execution_role
  }
}
```

Note on `lambda-config.execution_role` When specified, no additional role and policy will be created and `additional-permissions` will be ignored.

### additional-permissions

A list of json policy statment. Example Use

```hcl
module "user_input_lambda" {
  source = "./modules/lambda"
  additional-permissions = [
    {
      name = "sqs-input"
      policy = {
        Version = "2012-10-17"
        Statement = [{
          Effect = "Allow",
          Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
          Resource = ["${aws_sqs_queue.request-writer.arn}"]
        }]
      }
    },
    {
      name = "dynamodb-permission"
      policy = {
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow",
          Action   = ["dynamodb:PutItem"],
          Resource = ["${aws_dynamodb_table.request.arn}"]
        }]
      }
    }
  ]
}
```

### additional-environment-variables

```hcl
additional-environment-variables = {
  "REQUEST_TABLE_NAME" = "${aws_dynamodb_table.request.arn}"
}
```

## Outputs

| name            | description                                     |
| --------------- | ----------------------------------------------- |
| lambda_function | The lambda function object                      |
| lambda_role     | The role object created for the lambda function |
| cloudwatch      | The cloudwatch log group object created         |

## Example

```hcl
data "archive_file" "lambda_function-user_request" {
  // Zip file of the lambda function
  type        = "zip"
  source_dir  = "${path.module}/code/user_request"
  output_path = "${path.module}/code/user_request.zip"
}

module "lambda_function-user_request" {
  // Lambda Function Defination
  source = "./modules/lambda"

  aws-region  = var.aws-region
  prefix      = var.project-name
  name        = "user-request"
  description = "validate user input"

  source_code_zip_path = data.archive_file.lambda_function-user_request.output_path

  lambda-config = {
    handler        = "main.lambda_handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    timeout        = 10
    execution_role = var.lambda_function-user_request-execution_role
  }

  additional-permissions = [
    {
      name = "sqs-permission"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow",
            Action   = ["sqs:SendMessage"],
            Resource = ["${aws_sqs_queue.user_request.arn}"]
          }
        ]
      }
    }
  ]

  additional-environment-variables = {
    "SQS_QUEUE_URL" = "${aws_sqs_queue.user_request.url}"
  }
}
```
