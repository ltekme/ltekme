# User Input Lambda Function Module

This is just a lambda function rapped in a terraform module for a cleaner root module

## Inputs

| arg                         | default | description                                                       | type             |
| --------------------------- | ------- | ----------------------------------------------------------------- | ---------------- |
| aws-region                  |         | AWS Rrgion code to deploy the resources in                        | string           |
| prefix                      |         | Prefix to be added to all resources                               | string           |
| source_code_zip_path        |         | Path to the source code zip of the lambda function                | string           |
| name                        |         | Name of the lambda function                                       | string           |
| description                 | ""      | Description of the lambda function                                | string           |
| lambda-config               | {}      | Map of lambda function configurations                             | map(string)      |
| additional-permissions      | {}      | List of additional permissions to be added to the lambda function | map(map(string)) |
| create-cloudwatch-log-group | true    | Create CloudWatch Logs for the lambda function                    | bool             |

### lambda-config

Map of Lambda configurations. Example

```tf
module "user_input_lambda" {
  source = "./modules/lambda"
  lambda-config = {
    handler        = "main.handler"
    runtime        = "python3.12"
    architecture  = "arm64"
    execution_role = var.lambda_function-user_input-execution_role
  }
}
```

| arg                            | default                          | description                                            |
| ------------------------------ | -------------------------------- | ------------------------------------------------------ |
| `lambda-config.handler`        | "lambda_function.lambda_handler" | The lambda function handler                            |
| `lambda-config.runtime`        | "python3.12"                     | The runtime of the lambda function                     |
| `lambda-config.architecture`   | "arm64"                          | The architecture of the lambda function                |
| `lambda-config.execution_role` | null                             | The execution role which the lambda function will use. |

Note on `lambda-config.execution_role` When specified, no additional role and policy will be created and `additional-permissions` will be ignored.

### additional-permissions

A list of json policy statment. Example Use

```tf
module "user_input_lambda" {
  source = "./modules/lambda"
  additional-permissions = {
    permit_s3 = {
      Effect   = "Allow"
      Action   = "s3:GetObject"
      Resource = "*"
    }
  }
}
```

## Outputs

| name            | description                                     |
| --------------- | ----------------------------------------------- |
| lambda_function | The lambda function object                      |
| lambda_role     | The role object created for the lambda function |
| cloudwatch      | The cloudwatch log group object created         |

## Example

```tf
module "user_input_lambda" {
  // Lambda Function for User Input
  // Abstracted into module
  source = "./modules/lambda"

  aws-region      = var.aws-region
  resource-prefix = var.project_name
  name            = "user-input-lambda"
  description     = "Lambda Function Used to server user input"

  source_code_zip_path = data.archive_file.lambda_function-user_input.output_path

  lambda-config = {
    handler        = "main.handler"
    runtime        = "python3.12"
    architecture   = "arm64"
    execution_role = var.lambda_function-user_input-execution_role
  }

  additional-permissions = {
    permit_s3 = {
      Effect   = "Allow"
      Action   = "s3:GetObject"
      Resource = "*"
    }
  }
}
```
