# Working With APIGW and Lambda

This page is deedicated to working with HTTP API gateway API and Lambda Function as integration to serve as a back end API.

[↩️ go back](../../README.md)

## Table of Contents

- [Working With APIGW and Lambda](#working-with-apigw-and-lambda)
  - [Table of Contents](#table-of-contents)
  - [Python Lambda Function](#python-lambda-function)
    - [Handler](#handler)
    - [Debug and Logging](#debug-and-logging)
    - [Permissions](#permissions)
    - [Provisioning Lambda Function with Terraform](#provisioning-lambda-function-with-terraform)
      - [Setup Code zip for lambda function](#setup-code-zip-for-lambda-function)
  - [API Gateway](#api-gateway)
    - [The Gateway](#the-gateway)
      - [provisioning API Gateway](#provisioning-api-gateway)

## Python Lambda Function

Event triggered Lambda Function is basically. Lambda Functon Triggered by somethig. [read more](https://docs.aws.amazon.com/lambda/latest/operatorguide/event-driven-architectures.html)

In or case here, it is driven by API Gateway.

### Handler

Every lambda function have what's called an `entry point`. An `entry point` is the part that get called in the lambda function when a source triggers it.

![Lambda Function Console](<images/Screenshot 2024-08-15 162722.png>)

In AWS python lambda function event handler is formatted as `file name` **dot** `function name` -> `<-file name->.<-function name->`. In the above image the handler is set to `main.lambda_handler` and in the file `main.py` there is a function called `lambda_handler` that is the `entry point` for this lambda function.

[read more about handler](https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html)

### Debug and Logging

By default lambda function create a log streme in a cloud watch log group for each lambda function version.

Lambda function version is each time the code of a lambda function get changed and deployed.

![console lambda function](<images/Screenshot 2024-08-15 163217.png>)

The default log group of a lambda function is formatted as `/aws/lambda/<-function-name->`

There is no way to disable the loggin of the lambda function but the CloudWatch Log Group of where it create the log stream and it's format can be changed.

![Edit log setting page](<images/Screenshot 2024-08-15 163955.png>)

Every output on to the terminal when running the python code is logged in the log stream plus the start and end of the lambda function.

![CloudWatch Log Stream](<images/Screenshot 2024-08-15 164958.png>)

### Permissions

Much like every other aws services a role can be attached to a lambda function. My this means, the logging to cloudwatch can be disabled by not allowing it to create log stream.

![permission tab](<images/Screenshot 2024-08-15 170658.png>)

Allow Create log

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:us-east-1:<-account-id->:log-group:/aws/lambda/<-function-name->:*"
        }
    ]
}
```

### Provisioning Lambda Function with Terraform

This setup assumes following directory tree

```tree
.
├── code
│   └── demo
│       ├── helper.py
│       └── main.py
├── main.tf
├── output.tf
└── variables.tf
```

#### Setup Code zip for lambda function

```hcl
/*########################################################
User Input Lambda Module

########################################################*/
data "archive_file" "lambda_function-demo" {
  // Zip file of the lambda function code
  type        = "zip"
  source_dir  = "${path.module}/code/demo"
  output_path = "${path.module}/code/demo.zip"
}
```

## API Gateway

In my past experience when provisioning API Gateway with terraform. There is always a bug with provisioning REST API Gateway. Most likely because I don't know what I am doing.

But, most application can do all with HTTP API can get the job done.

Every API gateway api has a `gateway`, `stage`, and `resource`.

```text
https://8aaaaaa0.execute-api.us-east-1.amazonaws.com/AI_Content_Screener_API_Stage/dynamo_query
```

- API Entry URL
  
  `8aaaaaa0.execute-api.us-east-1.amazonaws.com`

- API Stage

  `AI_Content_Screener_API_Stage`

- Resource
  
  `dynamo_query`

---

### The Gateway

A gateway is the entry point of a request.

#### provisioning API Gateway
